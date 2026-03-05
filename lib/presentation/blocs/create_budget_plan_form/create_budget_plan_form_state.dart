import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';

/// Create Budget Plan Form States
abstract class CreateBudgetPlanFormState extends Equatable {
  const CreateBudgetPlanFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CreateBudgetPlanFormInitial extends CreateBudgetPlanFormState {}

/// Loading state
class CreateBudgetPlanFormLoading extends CreateBudgetPlanFormState {}

/// Form ready state
class CreateBudgetPlanFormReady extends CreateBudgetPlanFormState {
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPlanCategory category;
  final List<Map<String, dynamic>> milestones;
  final int accentColorValue;
  final int currentStep;

  CreateBudgetPlanFormReady({
    this.name = '',
    this.targetAmount = 0.0,
    this.currentAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.category = BudgetPlanCategory.custom,
    this.milestones = const [],
    this.accentColorValue = 0xFF4CAF82,
    this.currentStep = 0,
  }) : startDate = startDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now().add(const Duration(days: 365));

  @override
  List<Object?> get props => [
    name,
    targetAmount,
    currentAmount,
    startDate,
    endDate,
    category,
    milestones,
    accentColorValue,
    currentStep,
  ];

  CreateBudgetPlanFormReady copyWith({
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPlanCategory? category,
    List<Map<String, dynamic>>? milestones,
    int? accentColorValue,
    int? currentStep,
  }) {
    return CreateBudgetPlanFormReady(
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      milestones: milestones ?? this.milestones,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

/// Form error state
class CreateBudgetPlanFormError extends CreateBudgetPlanFormState {
  final String message;

  const CreateBudgetPlanFormError(this.message);

  @override
  List<Object> get props => [message];
}
