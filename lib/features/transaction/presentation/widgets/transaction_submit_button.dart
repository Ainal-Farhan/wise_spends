// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Transaction submit button widget
class TransactionSubmitButton extends StatelessWidget {
  final TransactionType transactionType;
  final bool isEditMode;
  final VoidCallback onPressed;

  const TransactionSubmitButton({
    super.key,
    required this.transactionType,
    required this.isEditMode,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final (label, color) = _getButtonConfig();

    return AppButton(
      variant: AppButtonVariant.primary,
      label: label,
      onPressed: onPressed,
    );
  }

  (String, Color) _getButtonConfig() {
    if (isEditMode) {
      return ('transactions.update_transaction'.tr, AppColors.primary);
    }

    return (transactionType.label, transactionType.color);
  }
}

/// Info banner for edit mode
class EditModeBanner extends StatelessWidget {
  const EditModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'transactions.edit_mode_info'.tr,
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
