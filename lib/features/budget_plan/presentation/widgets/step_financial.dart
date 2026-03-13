// FIXED: Extracted from budget_plans_forms.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'budget_plan_form_data.dart';
import 'budget_plan_form_widgets.dart';

/// Step 2: Financial - Target amount, start date, end date
class StepFinancial extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;
  final TextEditingController targetCtrl;
  final bool showStartDate;

  const StepFinancial({
    super.key,
    required this.data,
    required this.callbacks,
    required this.targetCtrl,
    this.showStartDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: 'budget_plans.step_financial'.tr,
            subtitle: 'budget_plans.step_financial_subtitle'.tr,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          FormSectionLabel(label: 'budget_plans.target_amount'.tr),
          const SizedBox(height: AppSpacing.sm),
          AmountField(
            controller: targetCtrl,
            onChanged: (v) =>
                callbacks.onTargetAmountChanged(double.tryParse(v) ?? 0.0),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (showStartDate) ...[
            DateField(
              labelKey: 'budget_plans.start_date_label',
              date: data.startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onChanged: callbacks.onStartDateChanged,
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          DateField(
            labelKey: 'budget_plans.target_date_label',
            date: data.endDate,
            firstDate: data.startDate,
            lastDate: DateTime(2100),
            onChanged: callbacks.onEndDateChanged,
          ),
        ],
      ),
    );
  }
}
