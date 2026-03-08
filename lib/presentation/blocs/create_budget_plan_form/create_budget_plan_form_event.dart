import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Create Budget Plan Form Events
abstract class CreateBudgetPlanFormEvent extends Equatable {
  const CreateBudgetPlanFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form
class InitializeCreateBudgetPlanForm extends CreateBudgetPlanFormEvent {
  const InitializeCreateBudgetPlanForm();
}

/// Change plan name
class ChangePlanName extends CreateBudgetPlanFormEvent {
  final String name;

  const ChangePlanName(this.name);

  @override
  List<Object> get props => [name];
}

/// Change target amount
class ChangeTargetAmount extends CreateBudgetPlanFormEvent {
  final double amount;

  const ChangeTargetAmount(this.amount);

  @override
  List<Object> get props => [amount];
}

/// Change current amount
class ChangeCurrentAmount extends CreateBudgetPlanFormEvent {
  final double amount;

  const ChangeCurrentAmount(this.amount);

  @override
  List<Object> get props => [amount];
}

/// Change start date
class ChangeStartDate extends CreateBudgetPlanFormEvent {
  final DateTime date;

  const ChangeStartDate(this.date);

  @override
  List<Object> get props => [date];
}

/// Change end date
class ChangeEndDate extends CreateBudgetPlanFormEvent {
  final DateTime date;

  const ChangeEndDate(this.date);

  @override
  List<Object> get props => [date];
}

/// Select category
class SelectBudgetPlanCategory extends CreateBudgetPlanFormEvent {
  final BudgetPlanCategory category;

  const SelectBudgetPlanCategory(this.category);

  @override
  List<Object> get props => [category];
}

/// Toggle milestone
class ToggleMilestone extends CreateBudgetPlanFormEvent {
  final int index;
  final bool isCompleted;

  const ToggleMilestone(this.index, this.isCompleted);

  @override
  List<Object> get props => [index, isCompleted];
}

/// Add milestone
class AddMilestone extends CreateBudgetPlanFormEvent {
  final String title;
  final double targetAmount;

  const AddMilestone(this.title, this.targetAmount);

  @override
  List<Object> get props => [title, targetAmount];
}

/// Remove milestone by index
class RemoveMilestone extends CreateBudgetPlanFormEvent {
  final int index;

  const RemoveMilestone(this.index);

  @override
  List<Object> get props => [index];
}

/// Clear form
class ClearCreateBudgetPlanForm extends CreateBudgetPlanFormEvent {}

/// Change accent color
class ChangeAccentColor extends CreateBudgetPlanFormEvent {
  final int colorValue;

  const ChangeAccentColor(this.colorValue);

  @override
  List<Object> get props => [colorValue];
}

/// Change current step
class ChangeCurrentStep extends CreateBudgetPlanFormEvent {
  final int step;

  const ChangeCurrentStep(this.step);

  @override
  List<Object> get props => [step];
}

/// Triggers the actual [IBudgetPlanRepository.createPlan] call.
/// Dispatched by [_CreateBudgetPlanContentState._submit] after
/// client-side validation passes.
class SaveCreateBudgetPlan extends CreateBudgetPlanFormEvent {
  const SaveCreateBudgetPlan();
}
