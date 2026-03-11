import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';

/// Budget Plan List BLoC States
abstract class BudgetPlanListState extends Equatable {
  const BudgetPlanListState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class BudgetPlanListInitial extends BudgetPlanListState {}

/// Loading state
class BudgetPlanListLoading extends BudgetPlanListState {}

/// Loaded state with plans
class BudgetPlanListLoaded extends BudgetPlanListState {
  final List<BudgetPlanEntity> plans;
  final List<BudgetPlanEntity> filteredPlans;
  final BudgetPlanSummary summary;
  final BudgetPlanStatus? filterStatus;
  final BudgetPlanCategory? filterCategory;

  const BudgetPlanListLoaded({
    required this.plans,
    required this.filteredPlans,
    required this.summary,
    this.filterStatus,
    this.filterCategory,
  });

  @override
  List<Object?> get props => [
    plans,
    filteredPlans,
    summary,
    filterStatus,
    filterCategory,
  ];

  BudgetPlanListLoaded copyWith({
    List<BudgetPlanEntity>? plans,
    List<BudgetPlanEntity>? filteredPlans,
    BudgetPlanSummary? summary,
    BudgetPlanStatus? filterStatus,
    BudgetPlanCategory? filterCategory,
  }) {
    return BudgetPlanListLoaded(
      plans: plans ?? this.plans,
      filteredPlans: filteredPlans ?? this.filteredPlans,
      summary: summary ?? this.summary,
      filterStatus: filterStatus ?? this.filterStatus,
      filterCategory: filterCategory ?? this.filterCategory,
    );
  }
}

/// Error state
class BudgetPlanListError extends BudgetPlanListState {
  final String message;

  const BudgetPlanListError(this.message);

  @override
  List<Object> get props => [message];
}

/// Empty state
class BudgetPlanListEmpty extends BudgetPlanListState {
  final String message;

  const BudgetPlanListEmpty([this.message = 'No budget plans yet']);

  @override
  List<Object> get props => [message];
}

// ADD these two new states to budget_plan_list_state.dart
// (after the existing BudgetPlanListError class)

/// Emitted when a delete operation fails.
/// Carries [previousState] so the screen can restore the list immediately
/// while showing the error message as a snackbar.
class BudgetPlanListDeleteError extends BudgetPlanListState {
  final String message;
  final BudgetPlanListLoaded? previousState;

  const BudgetPlanListDeleteError({required this.message, this.previousState});

  @override
  List<Object?> get props => [message, previousState];
}

/// Emitted when a pull-to-refresh fails but a valid list is already showing.
/// The bloc immediately re-emits the [previousState] after this, so the list
/// is never replaced; the screen should listen for this state and show a
/// snackbar.
class BudgetPlanListRefreshError extends BudgetPlanListState {
  final String message;
  final BudgetPlanListLoaded previousState;

  const BudgetPlanListRefreshError({
    required this.message,
    required this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Emitted when a recalculate operation fails.
/// Carries [previousState] so the screen can restore the list immediately
/// while showing the error message as a snackbar.
class BudgetPlanListRecalculateError extends BudgetPlanListState {
  final String message;
  final BudgetPlanListLoaded? previousState;

  const BudgetPlanListRecalculateError({
    required this.message,
    this.previousState,
  });

  @override
  List<Object?> get props => [message, previousState];
}

/// Emitted when a recalculate operation succeeds.
/// Useful to show a success message to the user.
class BudgetPlanListRecalculated extends BudgetPlanListState {
  final BudgetPlanListLoaded previousState;

  const BudgetPlanListRecalculated({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}
