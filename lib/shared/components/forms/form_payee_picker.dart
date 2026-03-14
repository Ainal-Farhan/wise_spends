// form_payee_picker.dart
// Reusable payee picker with dropdown and selected state
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _logger = WiseLogger();

/// Payee item for the picker
class FormPayeeItem {
  final String id;
  final String? name;
  final String? bankName;
  final String? accountNumber;

  const FormPayeeItem({
    required this.id,
    this.name,
    this.bankName,
    this.accountNumber,
  });

  String get displayName => name ?? 'transaction.unknown'.tr;

  String? get subtitle {
    final parts = [?bankName, ?accountNumber];
    return parts.isNotEmpty ? parts.join(' · ') : null;
  }
}

class FormPayeePicker extends StatelessWidget {
  final FormPayeeItem? selectedPayee;
  final List<FormPayeeItem> payees;
  final String? label;
  final String? hint;
  final bool enabled;
  final bool showOptionalLabel;
  final ValueChanged<FormPayeeItem?> onPayeeSelected;

  const FormPayeePicker({
    super.key,
    this.selectedPayee,
    required this.payees,
    this.label,
    this.hint,
    this.enabled = true,
    this.showOptionalLabel = true,
    required this.onPayeeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          _SectionLabel(
            text: label!,
            optionalSuffix: showOptionalLabel
                ? '(${'general.optional'.tr})'
                : null,
          ),
        if (label != null) const SizedBox(height: 10),

        if (selectedPayee != null) ...[
          SelectedPayeeChip(
            payee: selectedPayee!,
            onClear: enabled ? () {
              _logger.debug('Payee cleared', tag: 'FormPayeePicker');
              onPayeeSelected(null);
            } : null,
          ),
        ] else if (payees.isEmpty)
          _NoPayeesHint()
        else
          _PayeeDropdown(
            payees: payees,
            selectedPayee: selectedPayee,
            hint: hint ?? 'transaction.payee.select_hint'.tr,
            enabled: enabled,
            onChanged: (payee) {
              if (payee != null) {
                _logger.debug(
                  'Payee selected: ${payee.name} (${payee.id})',
                  tag: 'FormPayeePicker',
                );
              }
              onPayeeSelected(payee);
            },
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payee dropdown
// ─────────────────────────────────────────────────────────────────────────────

class _PayeeDropdown extends StatelessWidget {
  final List<FormPayeeItem> payees;
  final FormPayeeItem? selectedPayee;
  final String hint;
  final bool enabled;
  final ValueChanged<FormPayeeItem?> onChanged;

  const _PayeeDropdown({
    required this.payees,
    required this.selectedPayee,
    required this.hint,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonFormField<FormPayeeItem?>(
        initialValue: payees.any((p) => p.id == selectedPayee?.id)
            ? selectedPayee
            : null,
        isExpanded: true,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: const Icon(
              Icons.person_search_rounded,
              color: AppColors.textSecondary,
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
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
        ),
        items: payees.map((p) {
          return DropdownMenuItem<FormPayeeItem>(
            value: p,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  p.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (p.subtitle != null)
                  Text(
                    p.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          );
        }).toList(),
        onChanged: enabled
            ? (FormPayeeItem? value) {
                onChanged(value);
              }
            : null,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Selected payee chip
// ─────────────────────────────────────────────────────────────────────────────

class SelectedPayeeChip extends StatelessWidget {
  final FormPayeeItem payee;
  final VoidCallback? onClear;

  const SelectedPayeeChip({super.key, required this.payee, this.onClear});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee.displayName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payee.subtitle != null)
                  Text(
                    payee.subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary.withValues(alpha: 0.65),
                    ),
                  ),
              ],
            ),
          ),
          if (onClear != null)
            GestureDetector(
              onTap: onClear,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// No payees hint
// ─────────────────────────────────────────────────────────────────────────────

class _NoPayeesHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.person_outline_rounded,
            color: AppColors.textSecondary,
            size: 18,
          ),
          const SizedBox(width: 10),
          Text(
            'transaction.payee.no_payees'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  final String? optionalSuffix;

  const _SectionLabel({required this.text, this.optionalSuffix});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(text, style: AppTextStyles.bodySemiBold),
        if (optionalSuffix != null) ...[
          const SizedBox(width: 5),
          Text(
            optionalSuffix!,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
          ),
        ],
      ],
    );
  }
}
