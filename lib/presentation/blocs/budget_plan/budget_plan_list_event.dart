import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Budget Plan List BLoC Events
abstract class BudgetPlanListEvent extends Equatable {
  const BudgetPlanListEvent();

  @override
  List<Object?> get props => [];
}

/// Load all budget plans
class LoadBudgetPlans extends BudgetPlanListEvent {}

/// Filter budget plans
class FilterBudgetPlans extends BudgetPlanListEvent {
  final BudgetPlanStatus? status;
  final BudgetPlanCategory? category;

  const FilterBudgetPlans({this.status, this.category});

  @override
  List<Object?> get props => [status, category];
}

/// Delete a budget plan
class DeleteBudgetPlan extends BudgetPlanListEvent {
  final String uuid;

  const DeleteBudgetPlan(this.uuid);

  @override
  List<Object> get props => [uuid];
}

/// Refresh budget plans
class RefreshBudgetPlans extends BudgetPlanListEvent {}

/// Recalculate budget plans amounts
class RecalculateBudgetPlans extends BudgetPlanListEvent {}
