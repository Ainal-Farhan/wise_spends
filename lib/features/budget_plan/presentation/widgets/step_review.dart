// FIXED: Extracted from budget_plans_forms.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/shared/components/app_card.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'budget_plan_form_data.dart';
import 'budget_plan_form_widgets.dart';

/// Step 4: Review - Summary of all plan details
class StepReview extends StatelessWidget {
  final BudgetPlanFormData data;
  final bool showMilestones;

  const StepReview({super.key, required this.data, this.showMilestones = true});

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
            title: 'budget_plans.step_review'.tr,
            subtitle: 'budget_plans.review_subtitle'.tr,
            icon: Icons.checklist_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Plan summary card
          AppCard(
            child: Column(
              children: [
                // Accent color band + name header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Color(data.accentColorValue).withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Color(data.accentColorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          data.name.isNotEmpty
                              ? data.name
                              : 'budget_plans.unnamed'.tr,
                          style: AppTextStyles.bodySemiBold,
                        ),
                      ),
                      CategoryBadge(category: data.category),
                    ],
                  ),
                ),
                ReviewRow(
                  icon: Icons.flag_outlined,
                  label: 'budget_plans.target_amount'.tr,
                  value: 'RM ${data.targetAmount.toStringAsFixed(2)}',
                  highlight: true,
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                ReviewRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'budget_plans.start_date_label'.tr,
                  value: DateFormat('MMM d, y').format(data.startDate),
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                ReviewRow(
                  icon: Icons.event_outlined,
                  label: 'budget_plans.target_date_label'.tr,
                  value: DateFormat('MMM d, y').format(data.endDate),
                ),
                if (data.description.isNotEmpty) ...[
                  const Divider(height: 1, indent: AppSpacing.lg),
                  ReviewRow(
                    icon: Icons.notes_outlined,
                    label: 'budget_plans.description'.tr,
                    value: data.description,
                  ),
                ],
              ],
            ),
          ),

          // Milestones summary
          if (showMilestones && data.milestones.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.lg),
            FormSectionLabel(label: 'budget_plans.step_milestones'.tr),
            const SizedBox(height: AppSpacing.sm),
            ...data.milestones.asMap().entries.map(
              (e) => MilestoneSummaryTile(
                index: e.key,
                milestone: e.value,
                accentColor: Color(data.accentColorValue),
              ),
            ),
          ],

          if (showMilestones && data.milestones.isEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'budget_plans.no_milestones_review'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Review row widget for summary display
class ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const ReviewRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.sm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(
            value,
            style: highlight
                ? AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  )
                : AppTextStyles.bodySemiBold,
          ),
        ],
      ),
    );
  }
}

/// Category badge widget
class CategoryBadge extends StatelessWidget {
  final BudgetPlanCategory category;

  const CategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.iconCode, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(category.displayName, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// Milestone summary tile widget
class MilestoneSummaryTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> milestone;
  final Color accentColor;

  const MilestoneSummaryTile({
    super.key,
    required this.index,
    required this.milestone,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = milestone['title'] as String;
    final amount = milestone['amount'] as double;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: accentColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: AppTextStyles.labelMedium.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'RM ${amount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
