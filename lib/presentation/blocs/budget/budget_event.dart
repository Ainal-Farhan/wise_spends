import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';

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
  final DateTime endDate;
  final bool isRecurring;

  const CreateBudgetEvent({
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.startDate,
    required this.endDate,
    this.isRecurring = true,
  });

  @override
  List<Object?> get props => [
        name,
        amount,
        categoryId,
        startDate,
        endDate,
        isRecurring,
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

  const UpdateBudgetEvent({
    required this.budgetId,
    this.name,
    this.amount,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.isRecurring,
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

// ============================================================================
// REFRESH EVENTS
// ============================================================================

/// Refresh budgets (pull-to-refresh)
class RefreshBudgetsEvent extends BudgetEvent {}

/// Reload budgets
class ReloadBudgetsEvent extends BudgetEvent {}

/// Filter budgets by period
class FilterBudgetsByPeriodEvent extends BudgetEvent {
  final BudgetPeriod? period;

  const FilterBudgetsByPeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}

/// Clear budget filters
class ClearBudgetFiltersEvent extends BudgetEvent {}
