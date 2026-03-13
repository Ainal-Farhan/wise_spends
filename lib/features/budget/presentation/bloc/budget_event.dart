import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';

/// Budget BLoC events
abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// LOAD EVENTS
// ============================================================================

/// Load all budgets
class LoadBudgetsEvent extends BudgetEvent {}

/// Load active budgets only
class LoadActiveBudgetsEvent extends BudgetEvent {}

/// Load budgets by category
class LoadBudgetsByCategoryEvent extends BudgetEvent {
  final String categoryId;

  const LoadBudgetsByCategoryEvent(this.categoryId);

  @override
  List<Object> get props => [categoryId];
}

// ============================================================================
// CREATE/UPDATE/DELETE EVENTS
// ============================================================================

/// Create a new budget
class CreateBudgetEvent extends BudgetEvent {
  final String name;
  final double amount;
  final String categoryId;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isRecurring;
  final BudgetPeriod period;

  const CreateBudgetEvent({
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.startDate,
    this.endDate,
    this.isRecurring = true,
    this.period = BudgetPeriod.monthly,
  });

  @override
  List<Object?> get props => [
    name,
    amount,
    categoryId,
    startDate,
    endDate,
    isRecurring,
    period,
  ];
}

/// Update an existing budget
class UpdateBudgetEvent extends BudgetEvent {
  final String budgetId;
  final String? name;
  final double? amount;
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? isRecurring;
  final BudgetPeriod? period;
  final bool? isActive;

  const UpdateBudgetEvent({
    required this.budgetId,
    this.name,
    this.amount,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.isRecurring,
    this.period,
    this.isActive,
  });

  @override
  List<Object?> get props => [
    budgetId,
    name,
    amount,
    categoryId,
    startDate,
    endDate,
    isRecurring,
    period,
    isActive,
  ];
}

/// Delete a budget
class DeleteBudgetEvent extends BudgetEvent {
  final String budgetId;

  const DeleteBudgetEvent(this.budgetId);

  @override
  List<Object> get props => [budgetId];
}

/// Delete multiple budgets
class DeleteMultipleBudgetsEvent extends BudgetEvent {
  final List<String> budgetIds;

  const DeleteMultipleBudgetsEvent(this.budgetIds);

  @override
  List<Object> get props => [budgetIds];
}

/// Toggle budget active status
class ToggleBudgetActiveEvent extends BudgetEvent {
  final String budgetId;
  final bool isActive;

  const ToggleBudgetActiveEvent({
    required this.budgetId,
    required this.isActive,
  });

  @override
  List<Object> get props => [budgetId, isActive];
}

// ============================================================================
// SPENT AMOUNT EVENTS
// ============================================================================

/// Update spent amount for a specific budget (e.g. after a transaction)
class UpdateBudgetSpentAmountEvent extends BudgetEvent {
  final String budgetId;
  final double spentAmount;

  const UpdateBudgetSpentAmountEvent({
    required this.budgetId,
    required this.spentAmount,
  });

  @override
  List<Object> get props => [budgetId, spentAmount];
}

// ============================================================================
// REFRESH EVENTS
// ============================================================================

/// Refresh budgets (pull-to-refresh)
class RefreshBudgetsEvent extends BudgetEvent {}

/// Reload budgets
class ReloadBudgetsEvent extends BudgetEvent {}

// ============================================================================
// FILTER EVENTS
// ============================================================================

/// Filter budgets by period
class FilterBudgetsByPeriodEvent extends BudgetEvent {
  final BudgetPeriod? period;

  const FilterBudgetsByPeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

/// Clear budget filters
class ClearBudgetFiltersEvent extends BudgetEvent {}

// ============================================================================
// SYNC EVENTS
// ============================================================================

/// Recalculate spentAmount for ALL active budgets at once.
/// Dispatch on screen open to ensure progress bars always reflect real data.
class SyncAllBudgetsSpentAmountEvent extends BudgetEvent {
  const SyncAllBudgetsSpentAmountEvent();
}

/// Recalculate and persist spentAmount for every active budget whose category
/// and date range cover the given transaction.
///
/// Dispatch this from TransactionBloc after any save / edit / delete so that
/// budget progress bars always reflect the real transaction total.
class SyncBudgetSpentAmountEvent extends BudgetEvent {
  /// The category of the transaction that changed.
  final String categoryId;

  /// The date of the transaction — used to find which budgets it falls under.
  final DateTime transactionDate;

  const SyncBudgetSpentAmountEvent({
    required this.categoryId,
    required this.transactionDate,
  });

  @override
  List<Object> get props => [categoryId, transactionDate];
}
