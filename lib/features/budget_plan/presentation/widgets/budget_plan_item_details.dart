// FIXED: Extracted from add_edit_budget_plan_item_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// BIL stepper widget for incrementing/decrementing BIL number
class BilStepper extends StatelessWidget {
  final TextEditingController controller;

  const BilStepper({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.remove, size: 18),
          onPressed: () {
            final current = int.tryParse(controller.text) ?? 0;
            if (current > 0) controller.text = (current - 1).toString();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: 48,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add, size: 18),
          onPressed: () {
            final current = int.tryParse(controller.text) ?? 0;
            controller.text = (current + 1).toString();
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

/// Currency text field widget
class CurrencyTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CurrencyTextField({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hint: hint,
      controller: controller,
      prefixText: 'RM ',
      keyboardType: AppTextFieldKeyboardType.currency,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      validator: validator,
    );
  }
}

/// Item details card with BIL, name, and total cost fields
class ItemDetailsCard extends StatelessWidget {
  final TextEditingController bilCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController totalCostCtrl;

  const ItemDetailsCard({
    super.key,
    required this.bilCtrl,
    required this.nameCtrl,
    required this.totalCostCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bil',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              BilStepper(controller: bilCtrl),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: WiseSpendsColors.divider),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'budget_plans.item_name'.tr,
            hint: 'budget_plans.item_name_hint'.tr,
            controller: nameCtrl,
            prefixIcon: Icons.format_list_bulleted,
            maxLines: 2,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'error.validation.required'.tr
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyTextField(
            label: 'budget_plans.total_cost'.tr,
            hint: '0.00',
            controller: totalCostCtrl,
            validator: (v) {
              if (v == null || v.isEmpty) return 'error.validation.required'.tr;
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) {
                return 'error.validation.invalid_amount'.tr;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}
