import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';

/// Budget BLoC states
abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIAL & LOADING STATES
// ============================================================================

/// Initial state
class BudgetInitial extends BudgetState {}

/// Loading state
class BudgetLoading extends BudgetState {}

// ============================================================================
// SUCCESS STATES
// ============================================================================

/// Budgets loaded successfully
class BudgetsLoaded extends BudgetState {
  final List<dynamic> budgets; // Using dynamic to avoid circular dependency
  final int activeCount;
  final int onTrackCount;
  final BudgetPeriod? filterPeriod;

  const BudgetsLoaded({
    required this.budgets,
    this.activeCount = 0,
    this.onTrackCount = 0,
    this.filterPeriod,
  });

  @override
  List<Object?> get props => [budgets, activeCount, onTrackCount, filterPeriod];
}

/// Single budget loaded
class BudgetLoaded extends BudgetState {
  final dynamic budget;

  const BudgetLoaded(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget created successfully
class BudgetCreated extends BudgetState {
  final dynamic budget;

  const BudgetCreated(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget updated successfully
class BudgetUpdated extends BudgetState {
  final dynamic budget;

  const BudgetUpdated(this.budget);

  @override
  List<Object> get props => [budget];
}

/// Budget deleted successfully
class BudgetDeleted extends BudgetState {
  final String budgetId;

  const BudgetDeleted(this.budgetId);

  @override
  List<Object> get props => [budgetId];
}

// ============================================================================
// ERROR STATES
// ============================================================================

/// Error state
class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object> get props => [message];
}

/// Empty state
class BudgetEmpty extends BudgetState {
  final String message;

  const BudgetEmpty([this.message = 'No budgets found']);

  @override
  List<Object> get props => [message];
}
