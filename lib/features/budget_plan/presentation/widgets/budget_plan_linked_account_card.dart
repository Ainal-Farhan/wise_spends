import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Linked account card widget
class LinkedAccountCard extends StatelessWidget {
  final LinkedAccountSummaryEntity account;
  final String planId;
  final void Function(String accountId, String planId) onUnlink;
  final void Function(String accountId, String planId, double newAmount) onEditAllocation;

  const LinkedAccountCard({
    super.key,
    required this.account,
    required this.planId,
    required this.onUnlink,
    required this.onEditAllocation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            Icons.savings_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: AppIconSize.md,
          ),
        ),
        title: Text(
          account.accountName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${'budget_plans.allocated'.tr}: RM ${account.allocatedAmount.toStringAsFixed(2)}',
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.tertiary,
                size: 20,
              ),
              tooltip: 'budget_plans.edit_allocation'.tr,
              onPressed: () => onEditAllocation(
                account.accountId,
                planId,
                account.allocatedAmount,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.link_off,
                color: Theme.of(context).colorScheme.outline,
                size: 20,
              ),
              tooltip: 'budget_plans.unlink'.tr,
              onPressed: () => onUnlink(account.accountId, planId),
            ),
          ],
        ),
      ),
    );
  }
}
