// FIXED: Extracted from budget_plans_forms.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';

/// Immutable snapshot of the common form fields used by every step widget.
class BudgetPlanFormData {
  final String name;
  final String description;
  final BudgetPlanCategory category;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int accentColorValue;
  final List<Map<String, dynamic>> milestones;
  final int currentStep;
  final bool isLoading;

  const BudgetPlanFormData({
    required this.name,
    required this.description,
    required this.category,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    required this.accentColorValue,
    required this.milestones,
    required this.currentStep,
    required this.isLoading,
  });
}

/// Callback interface for form changes
class BudgetPlanFormCallbacks {
  final ValueChanged<String> onNameChanged;
  final ValueChanged<BudgetPlanCategory> onCategoryChanged;
  final ValueChanged<int> onAccentColorChanged;
  final ValueChanged<double> onTargetAmountChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final void Function(String title, double amount)? onAddMilestone;
  final void Function(int index)? onRemoveMilestone;

  BudgetPlanFormCallbacks({
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onAccentColorChanged,
    required this.onTargetAmountChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.onAddMilestone,
    this.onRemoveMilestone,
  });
}
