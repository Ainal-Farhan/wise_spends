import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/amount_text.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Summary strip shown above the deposit/spending tab bar.
///
/// Displays three metric cells (deposited, spent, net) and a
/// proportional progress bar showing how much of the deposited
/// amount has been spent.
class TransactionSummaryStrip extends StatelessWidget {
  const TransactionSummaryStrip({
    super.key,
    required this.totalDeposited,
    required this.totalSpent,
    required this.net,
  });

  final double totalDeposited;
  final double totalSpent;
  final double net;

  @override
  Widget build(BuildContext context) {
    final spentRatio = totalDeposited > 0
        ? (totalSpent / totalDeposited).clamp(0.0, 1.0)
        : 0.0;
    final spentPct = (spentRatio * 100).toStringAsFixed(0);
    final remainPct = (100 - spentRatio * 100).toStringAsFixed(0);

    // Progress bar colour: green when healthy, amber when >80%, red when >100%
    final barColor = spentRatio >= 1.0
        ? WiseSpendsColors.error
        : spentRatio >= 0.8
        ? WiseSpendsColors.warning
        : WiseSpendsColors.success;

    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        border: Border(bottom: BorderSide(color: WiseSpendsColors.divider)),
      ),
      child: Column(
        children: [
          // ── Metric cells ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _SummaryCell(
                  label: 'budget_plans.deposits'.tr,
                  amount: totalDeposited,
                  color: WiseSpendsColors.success,
                  icon: Icons.south_outlined,
                ),
                _SummaryDivider(),
                _SummaryCell(
                  label: 'budget_plans.spending'.tr,
                  amount: totalSpent,
                  color: WiseSpendsColors.secondary,
                  icon: Icons.north_outlined,
                ),
                _SummaryDivider(),
                _SummaryCell(
                  label: 'budget_plans.net'.tr,
                  amount: net,
                  color: net >= 0
                      ? WiseSpendsColors.success
                      : WiseSpendsColors.error,
                  icon: net >= 0
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                ),
              ],
            ),
          ),

          // ── Progress bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$spentPct% ${'budget_plans.spent'.tr}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$remainPct% ${'budget_plans.remaining'.tr}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spentRatio,
                    backgroundColor: WiseSpendsColors.divider.withValues(
                      alpha: 0.5,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(barColor),
                    minHeight: 6,
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

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 11, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          AmountText(
            amount: amount,
            type: AmountType.neutral,
            showPrefix: false,
            style: AppTextStyles.bodySemiBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: WiseSpendsColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}
