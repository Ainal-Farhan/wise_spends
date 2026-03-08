import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Edit Budget Plan Form Events
abstract class EditBudgetPlanFormEvent extends Equatable {
  const EditBudgetPlanFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form with plan data
class InitializeEditBudgetPlan extends EditBudgetPlanFormEvent {
  final String planUuid;

  const InitializeEditBudgetPlan(this.planUuid);

  @override
  List<Object> get props => [planUuid];
}

/// Change plan name
class EditChangePlanName extends EditBudgetPlanFormEvent {
  final String name;

  const EditChangePlanName(this.name);

  @override
  List<Object> get props => [name];
}

/// Change target amount
class EditChangeTargetAmount extends EditBudgetPlanFormEvent {
  final double amount;

  const EditChangeTargetAmount(this.amount);

  @override
  List<Object> get props => [amount];
}

/// Change current amount
class EditChangeCurrentAmount extends EditBudgetPlanFormEvent {
  final double amount;

  const EditChangeCurrentAmount(this.amount);

  @override
  List<Object> get props => [amount];
}

/// Change start date
class EditChangeStartDate extends EditBudgetPlanFormEvent {
  final DateTime date;

  const EditChangeStartDate(this.date);

  @override
  List<Object> get props => [date];
}

/// Change end date
class EditChangeEndDate extends EditBudgetPlanFormEvent {
  final DateTime date;

  const EditChangeEndDate(this.date);

  @override
  List<Object> get props => [date];
}

/// Select category
class EditSelectCategory extends EditBudgetPlanFormEvent {
  final BudgetPlanCategory category;

  const EditSelectCategory(this.category);

  @override
  List<Object> get props => [category];
}

/// Change accent color
class EditChangeAccentColor extends EditBudgetPlanFormEvent {
  final int colorValue;

  const EditChangeAccentColor(this.colorValue);

  @override
  List<Object> get props => [colorValue];
}

/// Save plan
class SaveEditBudgetPlan extends EditBudgetPlanFormEvent {}

/// Navigate between wizard steps in the edit form.
class EditChangeStep extends EditBudgetPlanFormEvent {
  final int step;
  const EditChangeStep(this.step);
}
