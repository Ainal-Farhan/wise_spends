// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Account selector widget for transactions
class AccountSelector extends StatelessWidget {
  final String? selectedAccountId;
  final List<ListSavingVO> accounts;
  final ValueChanged<String?> onAccountSelected;
  final String label;

  const AccountSelector({
    super.key,
    required this.selectedAccountId,
    required this.accounts,
    required this.onAccountSelected,
    this.label = 'transactions.account',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => _showAccountSheet(context),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getSelectedAccountName(),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getSelectedAccountName() {
    if (selectedAccountId == null) return 'Select account';
    final account = accounts.firstWhere(
      (a) => a.saving.id == selectedAccountId,
      orElse: () => throw Exception('Account not found'),
    );
    return account.saving.name ?? 'Unknown';
  }

  void _showAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => AccountSelectionSheet(
        accounts: accounts,
        selectedAccountId: selectedAccountId,
        onAccountSelected: onAccountSelected,
      ),
    );
  }
}

/// Account selection bottom sheet
class AccountSelectionSheet extends StatelessWidget {
  final List<ListSavingVO> accounts;
  final String? selectedAccountId;
  final ValueChanged<String?> onAccountSelected;

  const AccountSelectionSheet({
    super.key,
    required this.accounts,
    this.selectedAccountId,
    required this.onAccountSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text('transactions.select_account'.tr, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          if (accounts.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Icon(
                      Icons.account_balance_outlined,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'transactions.no_accounts'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: accounts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final account = accounts[index];
                  return _AccountListTile(
                    account: account,
                    isSelected: account.saving.id == selectedAccountId,
                    onTap: () {
                      onAccountSelected(account.saving.id);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: AppButton.secondary(
              label: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountListTile extends StatelessWidget {
  final ListSavingVO account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountListTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                isSelected ? Icons.check_circle : Icons.account_balance,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.saving.name ?? 'Unknown',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'RM ${account.saving.currentAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
