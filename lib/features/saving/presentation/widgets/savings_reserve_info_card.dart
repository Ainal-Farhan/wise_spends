import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';
import 'package:wise_spends/shared/components/app_card.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Widget to display reservation summary for a savings account
/// Shows reserved amounts and transferable amount
class SavingsReserveInfoCard extends StatelessWidget {
  final SavingsReserveSummary reserveSummary;
  final VoidCallback? onTap;

  const SavingsReserveInfoCard({
    super.key,
    required this.reserveSummary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!reserveSummary.hasReservations) {
      return const SizedBox.shrink();
    }

    final currencyFormat = NumberFormat.currency(
      symbol: 'RM ',
      decimalDigits: 2,
    );

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.lock_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'savings.reserved_funds'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Reserved amount breakdown
          _buildReserveRow(
            context,
            label: 'savings.commitment_tasks'.tr,
            amount: reserveSummary.commitmentTaskReserved,
            icon: Icons.task_outlined,
          ),

          const SizedBox(height: AppSpacing.xs),

          _buildReserveRow(
            context,
            label: 'savings.budget_allocations'.tr,
            amount: reserveSummary.budgetPlanAllocationReserved,
            icon: Icons.pie_chart,
          ),

          const SizedBox(height: AppSpacing.md),

          // Divider
          Container(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),

          const SizedBox(height: AppSpacing.md),

          // Transferable amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'savings.transferable_amount'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    currencyFormat.format(reserveSummary.transferableAmount),
                    style: AppTextStyles.h2.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_downward,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'savings.available_for_use'.tr,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Show details button if there are reservations
          if (reserveSummary.reservations.isNotEmpty && onTap != null) ...[
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.list, size: 16),
                label: Text(
                  'savings.view_reservation_details'.tr,
                  style: AppTextStyles.labelLarge,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReserveRow(
    BuildContext context, {
    required String label,
    required double amount,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(amount),
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.error,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
