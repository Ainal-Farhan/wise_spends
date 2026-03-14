import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/amount_text.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Summary strip shown above the deposit/spending tab bar.
///
/// Displays four metric cells (deposited, spent, net, available) and a
/// proportional progress bar showing how much of the deposited
/// amount has been spent.
///
/// ## Available Amount Calculation
/// The available amount represents the total money currently accessible
/// for this budget plan, including:
/// - Manual deposits not yet spent
/// - Money allocated in linked accounts
/// - Payments made to items (depositPaid + amountPaid)
///
/// This is different from [net] which is simply deposited - spent.
class TransactionSummaryStrip extends StatelessWidget {
  const TransactionSummaryStrip({
    super.key,
    required this.totalDeposited,
    required this.totalSpent,
    required this.net,
    this.totalAvailable,
  });

  final double totalDeposited;
  final double totalSpent;
  final double net;

  /// Total available amount from all sources (currentAmount from plan)
  /// Includes: deposits, allocated funds, and item payments
  final double? totalAvailable;

  @override
  Widget build(BuildContext context) {
    final spentRatio = totalDeposited > 0
        ? (totalSpent / totalDeposited).clamp(0.0, 1.0)
        : 0.0;
    final spentPct = (spentRatio * 100).toStringAsFixed(0);
    final remainPct = (100 - spentRatio * 100).toStringAsFixed(0);

    // Progress bar colour: green when healthy, amber when >80%, red when >100%
    final barColor = spentRatio >= 1.0
        ? Theme.of(context).colorScheme.error
        : spentRatio >= 0.8
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.outline)),
      ),
      child: Column(
        children: [
          // ── Metric cells ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Column(
              children: [
                // First row: Deposits, Spending, Net
                Row(
                  children: [
                    _SummaryCell(
                      label: 'budget_plans.deposits'.tr,
                      amount: totalDeposited,
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.south_outlined,
                    ),
                    _SummaryDivider(),
                    _SummaryCell(
                      label: 'budget_plans.spending'.tr,
                      amount: totalSpent,
                      color: Theme.of(context).colorScheme.secondary,
                      icon: Icons.north_outlined,
                    ),
                    _SummaryDivider(),
                    _SummaryCell(
                      label: 'budget_plans.net'.tr,
                      amount: net,
                      color: net >= 0
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.error,
                      icon: net >= 0
                          ? Icons.trending_up_rounded
                          : Icons.trending_down_rounded,
                    ),
                  ],
                ),
                // Second row: Available (if provided)
                if (totalAvailable != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SummaryCell(
                        label: 'budget_plans.available'.tr,
                        amount: totalAvailable!,
                        color: totalAvailable! >= 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.error,
                        icon: Icons.account_balance_wallet_outlined,
                        isLarge: true,
                      ),
                    ],
                  ),
                ],
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '$remainPct% ${'budget_plans.remaining'.tr}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spentRatio,
                    backgroundColor: Theme.of(context).colorScheme.outline.withValues(
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
    this.isLarge = false,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  final bool isLarge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: isLarge ? 14 : 11, color: color),
              const SizedBox(width: 3),
              Text(
                label,
                style: (isLarge ? AppTextStyles.caption : AppTextStyles.captionSmall).copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isLarge ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          AmountText(
            amount: amount,
            type: AmountType.neutral,
            showPrefix: false,
            style: (isLarge ? AppTextStyles.bodyLarge : AppTextStyles.bodySemiBold).copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
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
      color: Theme.of(context).colorScheme.outline,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}
