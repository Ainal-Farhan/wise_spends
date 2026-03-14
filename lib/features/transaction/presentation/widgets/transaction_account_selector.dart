// transaction_account_selector.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'transaction_form_widgets.dart';

/// Single account selector dropdown
class TransactionAccountDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? selectedId;
  final List<ListSavingVO> savingsList;
  final String? excludeId;
  final ValueChanged<String?> onChanged;

  const TransactionAccountDropdown({
    super.key,
    required this.label,
    required this.hint,
    required this.selectedId,
    required this.savingsList,
    this.excludeId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final available = savingsList
        .where((s) => s.saving.id != excludeId)
        .toList();

    if (available.isEmpty) {
      return _NoAccountsHint();
    }

    final validSelectedId = available.any((s) => s.saving.id == selectedId)
        ? selectedId
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: label),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: validSelectedId,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(
                  Icons.account_balance_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 0,
                minHeight: 0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              filled: true,
              fillColor: Colors.transparent,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
            items: available.map((s) {
              return DropdownMenuItem<String>(
                value: s.saving.id,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _savingTypeIcon(s.saving.type),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            s.saving.name ?? 'transaction.account.unnamed'.tr,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'RM ${s.saving.currentAmount.toStringAsFixed(2)}',
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
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _savingTypeIcon(String type) {
    final (icon, color) = switch (type.toLowerCase()) {
      'cash' => (Icons.payments_rounded, AppColors.success),
      'bank' ||
      'bank_account' => (Icons.account_balance_rounded, AppColors.primary),
      'credit' ||
      'credit_card' => (Icons.credit_card_rounded, AppColors.secondary),
      'ewallet' ||
      'e_wallet' => (Icons.phone_android_rounded, AppColors.tertiary),
      'savings' => (Icons.savings_rounded, AppColors.income),
      _ => (Icons.account_balance_wallet_rounded, AppColors.textSecondary),
    };
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

/// Transfer between two accounts
class TransferAccountSelector extends StatelessWidget {
  final String? sourceAccountId;
  final String? destinationAccountId;
  final List<ListSavingVO> savingsList;
  final ValueChanged<String?> onSourceChanged;
  final ValueChanged<String?> onDestinationChanged;

  const TransferAccountSelector({
    super.key,
    required this.sourceAccountId,
    required this.destinationAccountId,
    required this.savingsList,
    required this.onSourceChanged,
    required this.onDestinationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: 'transaction.transfer.between_accounts'.tr),
        const SizedBox(height: 12),
        TransactionAccountDropdown(
          label: 'transaction.transfer.from'.tr,
          hint: 'transaction.transfer.from_hint'.tr,
          selectedId: sourceAccountId,
          savingsList: savingsList,
          excludeId: destinationAccountId,
          onChanged: onSourceChanged,
        ),
        const SizedBox(height: 10),
        Center(
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.divider),
            ),
            child: const Icon(
              Icons.arrow_downward_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ),
        ),
        const SizedBox(height: 10),
        TransactionAccountDropdown(
          label: 'transaction.transfer.to'.tr,
          hint: 'transaction.transfer.to_hint'.tr,
          selectedId: destinationAccountId,
          savingsList: savingsList,
          excludeId: sourceAccountId,
          onChanged: onDestinationChanged,
        ),
      ],
    );
  }
}

/// Chip showing account name — used in locked fields
class AccountChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;

  const AccountChip({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoAccountsHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 18,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'transaction.account.no_accounts'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
