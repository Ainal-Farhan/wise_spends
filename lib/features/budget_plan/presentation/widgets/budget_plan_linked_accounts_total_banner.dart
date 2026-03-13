import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Linked accounts total banner widget
class LinkedAccountsTotalBanner extends StatelessWidget {
  final List<LinkedAccountSummaryEntity> accounts;
  final double planTarget;

  const LinkedAccountsTotalBanner({
    super.key,
    required this.accounts,
    required this.planTarget,
  });

  @override
  Widget build(BuildContext context) {
    final totalAllocated = accounts.fold<double>(
      0.0,
      (s, a) => s + a.allocatedAmount,
    );
    final progress = planTarget > 0
        ? (totalAllocated / planTarget).clamp(0.0, 1.0)
        : 0.0;
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: WiseSpendsColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 16,
                color: WiseSpendsColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'budget_plans.total_allocated'.tr,
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${accounts.length} ${'budget_plans.accounts'.tr}',
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fmt.format(totalAllocated),
            style: AppTextStyles.amountMedium.copyWith(
              color: WiseSpendsColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: WiseSpendsColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(
                WiseSpendsColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% ${'budget_plans.of_target'.tr}',
            style: AppTextStyles.caption.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
