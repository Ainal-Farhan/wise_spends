import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_params.dart';
import 'budget_plan_detail_event.dart';
import 'budget_plan_detail_state.dart';

/// Budget Plan Detail BLoC - manages individual plan detail state
class BudgetPlanDetailBloc
    extends Bloc<BudgetPlanDetailEvent, BudgetPlanDetailState> {
  final IBudgetPlanRepository _repository;

  BudgetPlanDetailBloc(this._repository) : super(BudgetPlanDetailInitial()) {
    on<LoadPlanDetail>(_onLoadPlanDetail);
    on<AddDeposit>(_onAddDeposit);
    on<AddSpending>(_onAddSpending);
    on<AddMilestoneEvent>(_onAddMilestone);
    on<CompleteMilestoneEvent>(_onCompleteMilestone);
    on<DeleteMilestoneEvent>(_onDeleteMilestone);
    on<UnlinkAccountEvent>(_onUnlinkAccount);
    on<UpdatePlanStatusEvent>(_onUpdatePlanStatus);
    on<DeletePlanEvent>(_onDeletePlan);
    on<RefreshPlanEvent>(_onRefreshPlan);
    on<DeleteDeposit>(_onDeleteDeposit);
    on<DeleteSpending>(_onDeleteSpending);
    on<LinkAccountEvent>(_onLinkAccount);
  }

  /// Load plan detail with all related data
  Future<void> _onLoadPlanDetail(
    LoadPlanDetail event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    emit(BudgetPlanDetailLoading());
    try {
      final plan = await _repository.getPlanByUuid(event.id);

      if (plan == null) {
        emit(BudgetPlanNotFound());
        return;
      }

      final deposits = await _repository.getDeposits(event.id);
      final transactions = await _repository.getPlanTransactions(event.id);
      final milestones = await _repository.getMilestones(event.id);
      final linkedAccounts = await _repository
          .watchLinkedAccounts(event.id)
          .first;

      // Get analytics data
      PlanAnalyticsData? analytics;
      try {
        analytics = await _repository.getPlanAnalytics(event.id);
      } catch (_) {
        // Analytics is optional
      }

      emit(
        BudgetPlanDetailLoaded(
          plan: plan,
          deposits: deposits,
          transactions: transactions,
          milestones: milestones,
          linkedAccounts: linkedAccounts,
          analytics: analytics,
        ),
      );
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to load plan: ${e.toString()}'));
    }
  }

  /// Add deposit to plan
  Future<void> _onAddDeposit(
    AddDeposit event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      final deposit = await _repository.addDeposit(
        currentState.plan.id,
        AddDepositParams(
          amount: event.amount,
          note: event.note,
          source: event.source,
          depositDate: event.depositDate,
          linkedAccountId: event.linkedAccountId,
        ),
      );

      emit(DepositAdded(deposit));

      // Reload plan detail to get updated amounts
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to add deposit: ${e.toString()}'));
    }
  }

  /// Add spending to plan
  Future<void> _onAddSpending(
    AddSpending event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      final transaction = await _repository.addPlanTransaction(
        currentState.plan.id,
        AddPlanTransactionParams(
          amount: event.amount,
          description: event.description,
          vendor: event.vendor,
          receiptImagePath: event.receiptPath,
          transactionDate: event.transactionDate,
        ),
      );

      emit(SpendingAdded(transaction));

      // Reload plan detail to get updated amounts
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to add spending: ${e.toString()}'));
    }
  }

  /// Add milestone to plan
  Future<void> _onAddMilestone(
    AddMilestoneEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      final milestone = await _repository.addMilestone(
        currentState.plan.id,
        event.title,
        event.targetAmount,
        event.dueDate,
      );

      emit(MilestoneAdded(milestone));

      // Reload plan detail
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to add milestone: ${e.toString()}'));
    }
  }

  /// Complete milestone
  Future<void> _onCompleteMilestone(
    CompleteMilestoneEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      await _repository.completeMilestone(event.milestoneId);

      // Reload plan detail
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(
        BudgetPlanDetailError('Failed to complete milestone: ${e.toString()}'),
      );
    }
  }

  /// Delete milestone
  Future<void> _onDeleteMilestone(
    DeleteMilestoneEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      await _repository.deleteMilestone(event.milestoneId);

      // Reload plan detail
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(
        BudgetPlanDetailError('Failed to delete milestone: ${e.toString()}'),
      );
    }
  }

  /// Unlink account from plan
  Future<void> _onUnlinkAccount(
    UnlinkAccountEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      await _repository.unlinkAccount(currentState.plan.id, event.accountId);

      // Reload plan detail
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to unlink account: ${e.toString()}'));
    }
  }

  /// Update plan status
  Future<void> _onUpdatePlanStatus(
    UpdatePlanStatusEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;

    try {
      await _repository.updatePlanStatus(currentState.plan.id, event.status);

      // Reload plan detail
      add(LoadPlanDetail(currentState.plan.id));
    } catch (e) {
      emit(
        BudgetPlanDetailError('Failed to update plan status: ${e.toString()}'),
      );
    }
  }

  /// Delete plan
  Future<void> _onDeletePlan(
    DeletePlanEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    try {
      await _repository.deletePlan(event.id);
      emit(PlanDeleted(event.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to delete plan: ${e.toString()}'));
    }
  }

  /// Refresh plan data
  Future<void> _onRefreshPlan(
    RefreshPlanEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;

    final currentState = state as BudgetPlanDetailLoaded;
    add(LoadPlanDetail(currentState.plan.id));
  }

  Future<void> _onDeleteDeposit(
    DeleteDeposit event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;
    final current = state as BudgetPlanDetailLoaded;
    try {
      await _repository.deleteDeposit(event.depositId);
      add(LoadPlanDetail(current.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to delete deposit: ${e.toString()}'));
      emit(current);
    }
  }

  Future<void> _onDeleteSpending(
    DeleteSpending event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;
    final current = state as BudgetPlanDetailLoaded;
    try {
      await _repository.deletePlanTransaction(event.transactionId);
      add(LoadPlanDetail(current.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to delete spending: ${e.toString()}'));
      emit(current);
    }
  }

  Future<void> _onLinkAccount(
    LinkAccountEvent event,
    Emitter<BudgetPlanDetailState> emit,
  ) async {
    if (state is! BudgetPlanDetailLoaded) return;
    final current = state as BudgetPlanDetailLoaded;
    try {
      await _repository.linkAccount(
        current.plan.id,
        event.accountId,
        event.allocatedAmount,
      );
      add(LoadPlanDetail(current.plan.id));
    } catch (e) {
      emit(BudgetPlanDetailError('Failed to link account: ${e.toString()}'));
      emit(current);
    }
  }
}
