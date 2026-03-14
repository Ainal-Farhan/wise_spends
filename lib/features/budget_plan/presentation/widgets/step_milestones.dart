// FIXED: Extracted from budget_plans_forms.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'budget_plan_form_data.dart';
import 'budget_plan_form_widgets.dart';

/// Step 3: Milestones - Add/remove milestones
class StepMilestones extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;

  const StepMilestones({
    super.key,
    required this.data,
    required this.callbacks,
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
            title: 'budget_plans.step_milestones'.tr,
            subtitle: 'budget_plans.milestones_optional'.tr,
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.milestones.isEmpty)
            const EmptyMilestonesPlaceholder()
          else
            ...data.milestones.asMap().entries.map(
              (e) => MilestoneTile(
                key: ValueKey('milestone-${e.key}'),
                index: e.key,
                milestone: e.value,
                onDelete: () => callbacks.onRemoveMilestone?.call(e.key),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'budget_plans.add_milestone'.tr,
            icon: Icons.add,
            onPressed: () => _showAddMilestoneDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showCustomContentDialog(
      context: context,
      title: 'budget_plans.add_milestone_title'.tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'budget_plans.milestone_title'.tr,
            hint: 'budget_plans.milestone_title_hint'.tr,
            controller: titleCtrl,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'budget_plans.target_amount'.tr,
            hint: '0.00',
            prefixText: 'RM ',
            controller: amountCtrl,
            keyboardType: AppTextFieldKeyboardType.decimal,
          ),
        ],
      ),
      actions: [
        DialogAction(
          text: 'general.cancel'.tr,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          text: 'general.add'.tr,
          isPrimary: true,
          onPressed: () {
            final title = titleCtrl.text.trim();
            final amount = double.tryParse(amountCtrl.text) ?? 0.0;
            if (title.isNotEmpty && amount > 0) {
              callbacks.onAddMilestone?.call(title, amount);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

/// Empty milestones placeholder
class EmptyMilestonesPlaceholder extends StatelessWidget {
  const EmptyMilestonesPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'budget_plans.no_milestones_yet'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Milestone tile widget
class MilestoneTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> milestone;
  final VoidCallback onDelete;

  const MilestoneTile({
    super.key,
    required this.index,
    required this.milestone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = milestone['title'] as String;
    final amount = milestone['amount'] as double;

    return Dismissible(
      key: ValueKey('milestone-$index'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async => await showConfirmDialog(
        context: context,
        title: 'budget_plans.delete_milestone'.tr,
        message: 'budget_plans.delete_milestone_msg'.tr,
      ),
      onDismissed: (_) => onDelete(),
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              Icons.flag,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(title, style: AppTextStyles.bodyMedium),
          subtitle: Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.outline,
            ),
            onPressed: () => onDelete(),
          ),
        ),
      ),
    );
  }
}
