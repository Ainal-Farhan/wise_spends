import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Edit Budget Plan Form States
abstract class EditBudgetPlanFormState extends Equatable {
  const EditBudgetPlanFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class EditBudgetPlanFormInitial extends EditBudgetPlanFormState {}

/// Loading state
class EditBudgetPlanFormLoading extends EditBudgetPlanFormState {}

/// Form ready state
class EditBudgetPlanFormReady extends EditBudgetPlanFormState {
  final String planUuid;
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPlanCategory category;
  final int accentColorValue;
  final bool isLoading;

  EditBudgetPlanFormReady({
    this.planUuid = '',
    this.name = '',
    this.description = '',
    this.targetAmount = 0.0,
    this.currentAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.category = BudgetPlanCategory.custom,
    this.accentColorValue = 0xFF4CAF82,
    this.isLoading = false,
  }) : startDate = startDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now().add(const Duration(days: 365));

  @override
  List<Object?> get props => [
    planUuid,
    name,
    description,
    targetAmount,
    currentAmount,
    startDate,
    endDate,
    category,
    accentColorValue,
    isLoading,
  ];

  EditBudgetPlanFormReady copyWith({
    String? planUuid,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPlanCategory? category,
    int? accentColorValue,
    bool? isLoading,
  }) {
    return EditBudgetPlanFormReady(
      planUuid: planUuid ?? this.planUuid,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Form error state
class EditBudgetPlanFormError extends EditBudgetPlanFormState {
  final String message;

  const EditBudgetPlanFormError(this.message);

  @override
  List<Object> get props => [message];
}

/// Form success state
class EditBudgetPlanFormSuccess extends EditBudgetPlanFormState {
  final String message;

  const EditBudgetPlanFormSuccess(this.message);

  @override
  List<Object> get props => [message];
}
