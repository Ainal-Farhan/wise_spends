import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'budget_plan_list_event.dart';
import 'budget_plan_list_state.dart';

class BudgetPlanListBloc
    extends Bloc<BudgetPlanListEvent, BudgetPlanListState> {
  final IBudgetPlanRepository _repository;

  BudgetPlanListBloc(this._repository) : super(BudgetPlanListInitial()) {
    on<LoadBudgetPlans>(_onLoadBudgetPlans);
    on<FilterBudgetPlans>(_onFilterBudgetPlans);
    on<DeleteBudgetPlan>(_onDeleteBudgetPlan);
    on<RefreshBudgetPlans>(_onRefreshBudgetPlans);
    on<RecalculateBudgetPlans>(_onRecalculateBudgetPlans);
    on<UpdateBudgetPlanStatus>(_onUpdateBudgetPlanStatus);
  }

  // ---------------------------------------------------------------------------
  // Load — full load with Loading state (initial or forced reload)
  // ---------------------------------------------------------------------------

  Future<void> _onLoadBudgetPlans(
    LoadBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    emit(BudgetPlanListLoading());
    try {
      final plans = await _repository.getAllPlans();
      final summary = await _repository.getOverallSummary();

      if (plans.isEmpty) {
        emit(
          const BudgetPlanListEmpty(
            'No budget plans yet. Create your first financial goal!',
          ),
        );
      } else {
        // Preserve the active filter across reloads, defaulting to null
        // (show all) when there is no prior state to read from.
        final currentFilter = state is BudgetPlanListLoaded
            ? (state as BudgetPlanListLoaded).filterStatus
            : BudgetPlanStatus.active;
        final currentCategory = state is BudgetPlanListLoaded
            ? (state as BudgetPlanListLoaded).filterCategory
            : null;

        final filtered = _applyFilters(plans, currentFilter, currentCategory);
        emit(
          BudgetPlanListLoaded(
            plans: plans,
            filteredPlans: filtered,
            summary: summary,
            filterStatus: currentFilter,
            filterCategory: currentCategory,
          ),
        );
      }
    } catch (e) {
      emit(BudgetPlanListError('Failed to load budget plans: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Filter — client-side only, no DB round-trip
  // ---------------------------------------------------------------------------

  void _onFilterBudgetPlans(
    FilterBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) {
    if (state is BudgetPlanListLoaded) {
      final current = state as BudgetPlanListLoaded;
      final filtered = _applyFilters(
        current.plans,
        event.status,
        event.category,
      );
      emit(
        current.copyWith(
          filteredPlans: filtered,
          isClear: true,
          filterStatus: event.status,
          filterCategory: event.category,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Delete — preserves the visible list on failure
  // ---------------------------------------------------------------------------

  Future<void> _onDeleteBudgetPlan(
    DeleteBudgetPlan event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    // Snapshot the current loaded state so we can restore it on failure.
    final snapshot = state is BudgetPlanListLoaded
        ? state as BudgetPlanListLoaded
        : null;

    try {
      await _repository.deletePlan(event.uuid);
      // Silent reload — _onLoadBudgetPlans preserves the active filter.
      add(LoadBudgetPlans());
    } catch (e) {
      // Emit a transient error state that the screen converts to a snackbar,
      // then immediately restore the list so the user isn't left staring at
      // an error screen.
      emit(
        BudgetPlanListDeleteError(
          message: 'Failed to delete plan: ${e.toString()}',
          // Restore the last good list state so BlocListener can show
          // the snackbar while BlocBuilder keeps the current list visible.
          previousState: snapshot,
        ),
      );

      // If we had a list, put it back as the active state.
      if (snapshot != null) emit(snapshot);
    }
  }

  // ---------------------------------------------------------------------------
  // Refresh — no Loading flicker; silently reloads behind the RefreshIndicator
  // ---------------------------------------------------------------------------

  Future<void> _onRefreshBudgetPlans(
    RefreshBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    try {
      final plans = await _repository.getAllPlans();
      final summary = await _repository.getOverallSummary();

      if (plans.isEmpty) {
        emit(
          const BudgetPlanListEmpty(
            'No budget plans yet. Create your first financial goal!',
          ),
        );
        return;
      }

      final currentFilter = state is BudgetPlanListLoaded
          ? (state as BudgetPlanListLoaded).filterStatus
          : null;
      final currentCategory = state is BudgetPlanListLoaded
          ? (state as BudgetPlanListLoaded).filterCategory
          : null;

      final filtered = _applyFilters(plans, currentFilter, currentCategory);
      emit(
        BudgetPlanListLoaded(
          plans: plans,
          filteredPlans: filtered,
          summary: summary,
          filterStatus: currentFilter,
          filterCategory: currentCategory,
        ),
      );
    } catch (e) {
      // On refresh failure, only swap to the error state if there is no
      // existing list to show; otherwise the screen would go blank.
      if (state is! BudgetPlanListLoaded) {
        emit(BudgetPlanListError('Failed to refresh plans: ${e.toString()}'));
      }
      // If there is a loaded list already, stay on it and surface the error
      // via BudgetPlanListRefreshError so the UI can show a snackbar.
      else {
        emit(
          BudgetPlanListRefreshError(
            message: 'Failed to refresh: ${e.toString()}',
            previousState: state as BudgetPlanListLoaded,
          ),
        );
        emit(state); // re-emit loaded state so BlocBuilder stays stable
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Recalculate — recalculate all plan amounts without Loading flicker
  // ---------------------------------------------------------------------------

  Future<void> _onRecalculateBudgetPlans(
    RecalculateBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    // Snapshot the current loaded state so we can restore it on failure.
    final snapshot = state is BudgetPlanListLoaded
        ? state as BudgetPlanListLoaded
        : null;

    try {
      // Recalculate all plan amounts
      await _repository.recalculateAmounts();

      // After recalculation, reload the data to show updated amounts
      final plans = await _repository.getAllPlans();
      final summary = await _repository.getOverallSummary();

      if (plans.isEmpty) {
        emit(
          const BudgetPlanListEmpty(
            'No budget plans yet. Create your first financial goal!',
          ),
        );
        return;
      }

      final currentFilter = snapshot?.filterStatus;
      final currentCategory = snapshot?.filterCategory;

      final filtered = _applyFilters(plans, currentFilter, currentCategory);
      emit(
        BudgetPlanListLoaded(
          plans: plans,
          filteredPlans: filtered,
          summary: summary,
          filterStatus: currentFilter,
          filterCategory: currentCategory,
        ),
      );

      // Emit success state for UI to show confirmation
      emit(
        BudgetPlanListRecalculated(
          previousState: BudgetPlanListLoaded(
            plans: plans,
            filteredPlans: filtered,
            summary: summary,
            filterStatus: currentFilter,
            filterCategory: currentCategory,
          ),
        ),
      );
      // Re-emit loaded state so UI stays on the list
      emit(
        BudgetPlanListLoaded(
          plans: plans,
          filteredPlans: filtered,
          summary: summary,
          filterStatus: currentFilter,
          filterCategory: currentCategory,
        ),
      );
    } catch (e) {
      // Emit error state for UI to show error message
      emit(
        BudgetPlanListRecalculateError(
          message: 'Failed to recalculate: ${e.toString()}',
          previousState: snapshot,
        ),
      );

      // If we had a list, put it back as the active state.
      if (snapshot != null) emit(snapshot);
    }
  }

  // ---------------------------------------------------------------------------
  // Update Status — update plan status without Loading flicker
  // ---------------------------------------------------------------------------

  Future<void> _onUpdateBudgetPlanStatus(
    UpdateBudgetPlanStatus event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    // Snapshot the current loaded state so we can restore it on failure.
    final snapshot = state is BudgetPlanListLoaded
        ? state as BudgetPlanListLoaded
        : null;

    try {
      // Update the plan status
      await _repository.updatePlanStatus(event.uuid, event.status);

      // After update, reload the data to show updated status
      final plans = await _repository.getAllPlans();
      final summary = await _repository.getOverallSummary();

      if (plans.isEmpty) {
        emit(
          const BudgetPlanListEmpty(
            'No budget plans yet. Create your first financial goal!',
          ),
        );
        return;
      }

      final currentFilter = snapshot?.filterStatus;
      final currentCategory = snapshot?.filterCategory;

      final filtered = _applyFilters(plans, currentFilter, currentCategory);
      emit(
        BudgetPlanListLoaded(
          plans: plans,
          filteredPlans: filtered,
          summary: summary,
          filterStatus: currentFilter,
          filterCategory: currentCategory,
        ),
      );
    } catch (e) {
      // Emit error state for UI to show error message
      emit(BudgetPlanListError('Failed to update status: ${e.toString()}'));

      // If we had a list, put it back as the active state.
      if (snapshot != null) emit(snapshot);
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<BudgetPlanEntity> _applyFilters(
    List<BudgetPlanEntity> plans,
    BudgetPlanStatus? status,
    BudgetPlanCategory? category,
  ) {
    var filtered = plans;

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    if (category != null) {
      filtered = filtered.where((p) => p.category == category).toList();
    }

    return filtered;
  }
}
