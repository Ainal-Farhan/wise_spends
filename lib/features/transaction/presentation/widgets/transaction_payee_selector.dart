// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'transaction_form_widgets.dart';

/// Payee selector widget
class PayeeSelector extends StatelessWidget {
  final PayeeVO? selectedPayee;
  final VoidCallback onPayeeSelected;
  final VoidCallback? onClearPayee;

  const PayeeSelector({
    super.key,
    required this.selectedPayee,
    required this.onPayeeSelected,
    this.onClearPayee,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactions.payee'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (selectedPayee != null && onClearPayee != null) ...[
          SelectedPayeeChip(payee: selectedPayee!, onClear: onClearPayee!),
        ] else
          GestureDetector(
            onTap: onPayeeSelected,
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
                    Icons.person,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'transactions.select_payee'.tr,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const Spacer(),
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
}

/// Payee selection bottom sheet
class PayeeSelectionSheet extends StatelessWidget {
  final List<PayeeVO> payees;
  final ValueChanged<PayeeVO> onPayeeSelected;

  const PayeeSelectionSheet({
    super.key,
    required this.payees,
    required this.onPayeeSelected,
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
          Text('transactions.select_payee'.tr, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          if (payees.isEmpty) ...[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'transactions.no_payees'.tr,
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
                itemCount: payees.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final payee = payees[index];
                  return _PayeeListTile(
                    payee: payee,
                    onTap: () => onPayeeSelected(payee),
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

class _PayeeListTile extends StatelessWidget {
  final PayeeVO payee;
  final VoidCallback onTap;

  const _PayeeListTile({required this.payee, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    payee.name ?? 'Unknown',
                    style: AppTextStyles.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (payee.bankName != null || payee.accountNumber != null)
                    Text(
                      [
                        if (payee.bankName != null) payee.bankName!,
                        if (payee.accountNumber != null) payee.accountNumber!,
                      ].join(' · '),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}
