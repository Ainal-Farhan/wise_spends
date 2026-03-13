import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_milestone_entity.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Milestone card widget with dismissible functionality
class MilestoneCard extends StatelessWidget {
  final BudgetPlanMilestoneEntity milestone;
  final String planId;
  final void Function(String milestoneId, String planId) onComplete;
  final void Function(String milestoneId, String planId) onDelete;

  const MilestoneCard({
    super.key,
    required this.milestone,
    required this.planId,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('milestone_${milestone.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDeleteDialog(
        context: context,
        title: 'budget_plans.delete_milestone'.tr,
        message: 'budget_plans.delete_milestone_msg'.trWith({
          'title': milestone.title,
        }),
        deleteText: 'general.delete'.tr,
        cancelText: 'general.cancel'.tr,
      ),
      onDismissed: (_) => onDelete(milestone.id, planId),
      background: Container(
        decoration: BoxDecoration(
          color: WiseSpendsColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: MilestoneCardContent(
        milestone: milestone,
        planId: planId,
        onComplete: onComplete,
      ),
    );
  }
}

/// Milestone card content widget
class MilestoneCardContent extends StatelessWidget {
  final BudgetPlanMilestoneEntity milestone;
  final String planId;
  final void Function(String milestoneId, String planId) onComplete;

  const MilestoneCardContent({
    super.key,
    required this.milestone,
    required this.planId,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: milestone.isCompleted
              ? WiseSpendsColors.success.withValues(alpha: 0.2)
              : WiseSpendsColors.primary.withValues(alpha: 0.2),
          child: Icon(
            milestone.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: milestone.isCompleted
                ? WiseSpendsColors.success
                : WiseSpendsColors.primary,
          ),
        ),
        title: Text(
          milestone.title,
          style: TextStyle(
            decoration: milestone.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text('RM ${milestone.targetAmount.toStringAsFixed(2)}'),
        trailing: milestone.isCompleted
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => onComplete(milestone.id, planId),
              ),
      ),
    );
  }
}
