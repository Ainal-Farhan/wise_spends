import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Progress body widget - shows progress bar and status chips
class ProgressBody extends StatelessWidget {
  final BudgetPlanEntity plan;
  final Color color;

  const ProgressBody({super.key, required this.plan, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = plan.progressPercentage.clamp(0.0, 1.0);
    final healthStatus = plan.healthStatus;
    final String healthLabel;
    switch (healthStatus) {
      case BudgetHealthStatus.onTrack:
        healthLabel = 'budget_plans.health_on_track'.tr;
      case BudgetHealthStatus.slightlyBehind:
        healthLabel = 'budget_plans.health_slightly_behind'.tr;
      case BudgetHealthStatus.atRisk:
        healthLabel = 'budget_plans.health_at_risk'.tr;
      case BudgetHealthStatus.overBudget:
        healthLabel = 'budget_plans.health_over_budget'.tr;
      case BudgetHealthStatus.completed:
        healthLabel = 'budget_plans.health_completed'.tr;
    }
    final percentageDisplay = (progress * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            StatusChip(
              icon: healthStatus == BudgetHealthStatus.onTrack
                  ? Icons.check_circle
                  : Icons.warning,
              label: healthLabel,
            ),
            const SizedBox(width: AppSpacing.md),
            StatusChip(
              icon: Icons.calendar_today,
              label: '$percentageDisplay% ${'general.complete'.tr}',
            ),
          ],
        ),
      ],
    );
  }
}

/// Status chip widget
class StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const StatusChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.xs, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
