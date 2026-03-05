import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_entity.dart';
import 'package:wise_spends/domain/repositories/budget_plan_repository.dart';
import 'budget_plan_list_event.dart';
import 'budget_plan_list_state.dart';

/// Budget Plan List BLoC - manages list of budget plans
class BudgetPlanListBloc extends Bloc<BudgetPlanListEvent, BudgetPlanListState> {
  final IBudgetPlanRepository _repository;

  BudgetPlanListBloc(this._repository) : super(BudgetPlanListInitial()) {
    on<LoadBudgetPlans>(_onLoadBudgetPlans);
    on<FilterBudgetPlans>(_onFilterBudgetPlans);
    on<DeleteBudgetPlan>(_onDeleteBudgetPlan);
    on<RefreshBudgetPlans>(_onRefreshBudgetPlans);
  }

  /// Load all budget plans
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
        final filtered = _applyFilters(plans, null, null);
        emit(
          BudgetPlanListLoaded(
            plans: plans,
            filteredPlans: filtered,
            summary: summary,
          ),
        );
      }
    } catch (e) {
      emit(BudgetPlanListError('Failed to load budget plans: ${e.toString()}'));
    }
  }

  /// Filter budget plans
  Future<void> _onFilterBudgetPlans(
    FilterBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    if (state is BudgetPlanListLoaded) {
      final currentState = state as BudgetPlanListLoaded;
      final filtered = _applyFilters(
        currentState.plans,
        event.status,
        event.category,
      );
      emit(currentState.copyWith(
        filteredPlans: filtered,
        filterStatus: event.status,
        filterCategory: event.category,
      ));
    }
  }

  /// Delete a budget plan
  Future<void> _onDeleteBudgetPlan(
    DeleteBudgetPlan event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    try {
      await _repository.deletePlan(event.uuid);
      // Reload plans after deletion
      add(LoadBudgetPlans());
    } catch (e) {
      emit(BudgetPlanListError('Failed to delete plan: ${e.toString()}'));
    }
  }

  /// Refresh budget plans
  Future<void> _onRefreshBudgetPlans(
    RefreshBudgetPlans event,
    Emitter<BudgetPlanListState> emit,
  ) async {
    add(LoadBudgetPlans());
  }

  /// Apply filters to plans
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
