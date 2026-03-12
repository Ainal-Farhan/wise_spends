import 'package:equatable/equatable.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Base
// ─────────────────────────────────────────────────────────────────────────────

abstract class EditBudgetPlanFormState extends Equatable {
  const EditBudgetPlanFormState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading — shown while the existing plan data is being fetched
// ─────────────────────────────────────────────────────────────────────────────

class EditBudgetPlanFormLoading extends EditBudgetPlanFormState {
  @override
  List<Object?> get props => [];
}

// ─────────────────────────────────────────────────────────────────────────────
// Ready — all form fields are live and editable
// ─────────────────────────────────────────────────────────────────────────────

class EditBudgetPlanFormReady extends EditBudgetPlanFormState {
  // The plan's UUID — needed by the bloc to call updatePlan(id, ...).
  // This was MISSING from the original state, which is why saves were silently
  // dropped (the bloc had no id to pass to the repository).
  final String planId;

  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPlanCategory category;
  final int accentColorValue;
  final bool isLoading;
  final int currentStep;

  EditBudgetPlanFormReady({
    this.planId = '',
    this.name = '',
    this.description = '',
    this.targetAmount = 0.0,
    this.currentAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.category = BudgetPlanCategory.custom,
    int? accentColorValue,
    this.isLoading = false,
    this.currentStep = 0,
  }) : startDate = startDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now().add(const Duration(days: 365)),
       accentColorValue = accentColorValue ?? AppColors.primary.toARGB32();

  EditBudgetPlanFormReady copyWith({
    String? planId,
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPlanCategory? category,
    int? accentColorValue,
    bool? isLoading,
    int? currentStep,
  }) {
    return EditBudgetPlanFormReady(
      planId: planId ?? this.planId,
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      isLoading: isLoading ?? this.isLoading,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  @override
  List<Object?> get props => [
    planId,
    name,
    description,
    targetAmount,
    currentAmount,
    startDate,
    endDate,
    category,
    accentColorValue,
    isLoading,
    currentStep,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Terminal states
// ─────────────────────────────────────────────────────────────────────────────

class EditBudgetPlanFormSuccess extends EditBudgetPlanFormState {
  final String message;

  const EditBudgetPlanFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class EditBudgetPlanFormError extends EditBudgetPlanFormState {
  final String message;

  const EditBudgetPlanFormError(this.message);

  @override
  List<Object?> get props => [message];
}
