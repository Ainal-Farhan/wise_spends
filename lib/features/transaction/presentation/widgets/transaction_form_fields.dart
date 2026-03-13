// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Amount input field widget
class TransactionAmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const TransactionAmountField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactions.amount'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'transactions.amount'.tr,
          hint: '0.00',
          prefixText: 'RM ',
          controller: controller,
          keyboardType: AppTextFieldKeyboardType.decimal,
          textCapitalization: TextCapitalization.none,
          textAlign: TextAlign.left,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Title input field widget
class TransactionTitleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const TransactionTitleField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactions.title'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'transactions.title'.tr,
          hint: 'transactions.title_hint'.tr,
          controller: controller,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

/// Note input field widget
class TransactionNoteField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const TransactionNoteField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactions.note'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'transactions.note'.tr,
          hint: 'transactions.note_hint'.tr,
          controller: controller,
          maxLines: 3,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
