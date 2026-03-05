import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_entity.dart';
import 'package:wise_spends/domain/repositories/budget_plan_repository.dart';

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

  const BudgetPlanListLoaded({
    required this.plans,
    required this.filteredPlans,
    required this.summary,
  });

  @override
  List<Object> get props => [plans, filteredPlans, summary];

  BudgetPlanListLoaded copyWith({
    List<BudgetPlanEntity>? plans,
    List<BudgetPlanEntity>? filteredPlans,
    BudgetPlanSummary? summary,
  }) {
    return BudgetPlanListLoaded(
      plans: plans ?? this.plans,
      filteredPlans: filteredPlans ?? this.filteredPlans,
      summary: summary ?? this.summary,
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
