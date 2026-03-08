import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

abstract class CreateBudgetPlanFormState extends Equatable {
  const CreateBudgetPlanFormState();
}

// ─────────────────────────────────────────────────────────────────────────────
// Ready — all form fields live here; drives every step of the wizard
// ─────────────────────────────────────────────────────────────────────────────

class CreateBudgetPlanFormReady extends CreateBudgetPlanFormState {
  final String name;
  final String description;
  final double targetAmount;
  final double currentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final BudgetPlanCategory category;
  final int accentColorValue;
  final int currentStep;
  final List<Map<String, dynamic>> milestones;

  /// True while [SaveCreateBudgetPlan] is in flight — disables the submit
  /// button so the user can't double-tap.
  final bool isLoading;

  CreateBudgetPlanFormReady({
    this.name = '',
    this.description = '',
    this.targetAmount = 0.0,
    this.currentAmount = 0.0,
    DateTime? startDate,
    DateTime? endDate,
    this.category = BudgetPlanCategory.custom,
    int? accentColorValue,
    this.currentStep = 0,
    this.milestones = const [],
    this.isLoading = false,
  }) : startDate = startDate ?? DateTime.now(),
       endDate = endDate ?? DateTime.now().add(const Duration(days: 365)),
       accentColorValue = accentColorValue ?? AppColors.primary.toARGB32();

  CreateBudgetPlanFormReady copyWith({
    String? name,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? startDate,
    DateTime? endDate,
    BudgetPlanCategory? category,
    int? accentColorValue,
    int? currentStep,
    List<Map<String, dynamic>>? milestones,
    bool? isLoading,
  }) {
    return CreateBudgetPlanFormReady(
      name: name ?? this.name,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      category: category ?? this.category,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      currentStep: currentStep ?? this.currentStep,
      milestones: milestones ?? this.milestones,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
    name,
    description,
    targetAmount,
    currentAmount,
    startDate,
    endDate,
    category,
    accentColorValue,
    currentStep,
    milestones,
    isLoading,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Terminal states — emitted after the repository call completes
// ─────────────────────────────────────────────────────────────────────────────

/// Emitted after [_repository.createPlan] succeeds.
/// The screen listens for this to pop and show the success snackbar.
class CreateBudgetPlanFormSuccess extends CreateBudgetPlanFormState {
  final String message;

  const CreateBudgetPlanFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// Emitted when [_repository.createPlan] throws.
/// The screen listens for this to show an error snackbar while staying open.
class CreateBudgetPlanFormError extends CreateBudgetPlanFormState {
  final String message;

  const CreateBudgetPlanFormError(this.message);

  @override
  List<Object?> get props => [message];
}
