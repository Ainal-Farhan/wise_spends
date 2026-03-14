// FIXED: Extracted from add_edit_budget_plan_item_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Total paid summary card
class TotalPaidCard extends StatelessWidget {
  final double depositPaid;
  final double amountPaid;
  final double totalCost;
  final bool hasDeposit;

  const TotalPaidCard({
    super.key,
    required this.depositPaid,
    required this.amountPaid,
    required this.totalCost,
    required this.hasDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final totalPaid = depositPaid + amountPaid;
    final remaining = (totalCost - totalPaid).clamp(0.0, double.infinity);
    final progress = totalCost > 0
        ? (totalPaid / totalCost).clamp(0.0, 1.0)
        : 0.0;
    final isFullyPaid = totalCost > 0 && totalPaid >= totalCost;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isFullyPaid
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isFullyPaid
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
              : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isFullyPaid
                    ? Icons.check_circle
                    : Icons.account_balance_wallet_outlined,
                size: 15,
                color: isFullyPaid
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'budget_plans.total_paid_summary'.tr.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isFullyPaid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              if (isFullyPaid)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'budget_plans.fully_paid'.tr,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Breakdown row
          Row(
            children: [
              if (hasDeposit) ...[
                Expanded(
                  child: _SummaryValue(
                    label: 'budget_plans.deposit_paid_label'.tr,
                    value: 'RM ${NumberFormat('#,##0.00').format(depositPaid)}',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 1,
                  height: 36,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: _SummaryValue(
                  label: 'budget_plans.payment_paid_label'.tr,
                  value: 'RM ${NumberFormat('#,##0.00').format(amountPaid)}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(width: 1, height: 36, color: Theme.of(context).colorScheme.outline),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryValue(
                  label: 'budget_plans.total_paid_label'.tr,
                  value: 'RM ${NumberFormat('#,##0.00').format(totalPaid)}',
                  valueColor: isFullyPaid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isFullyPaid
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isFullyPaid ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.primary,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Remaining
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'budget_plans.remaining'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                'RM ${NumberFormat('#,##0.00').format(remaining)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isFullyPaid
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryValue({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              color: valueColor ?? Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
