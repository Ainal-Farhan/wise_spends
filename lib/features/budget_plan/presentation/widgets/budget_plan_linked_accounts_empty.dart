import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Linked accounts empty state widget
class LinkedAccountsEmpty extends StatelessWidget {
  final VoidCallback onLink;

  const LinkedAccountsEmpty({super.key, required this.onLink});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_outlined,
              size: 48,
              color: WiseSpendsColors.textSecondary,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('budget_plans.no_linked_accounts'.tr, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'budget_plans.link_account_to_allocate'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            TextButton.icon(
              onPressed: onLink,
              icon: const Icon(Icons.add_link),
              label: Text('budget_plans.link_account'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
