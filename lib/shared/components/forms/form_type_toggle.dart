// form_type_toggle.dart
// Reusable transaction type toggle (Expense/Income/Transfer)
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

final _logger = WiseLogger();

/// Transaction type for the form
enum FormTransactionType {
  expense(
    label: 'transaction.type.expense',
    icon: Icons.trending_down_rounded,
    color: AppColors.error,
  ),
  income(
    label: 'transaction.type.income',
    icon: Icons.trending_up_rounded,
    color: AppColors.success,
  ),
  transfer(
    label: 'transaction.type.transfer',
    icon: Icons.swap_horiz_rounded,
    color: AppColors.primary,
  );

  final String label;
  final IconData icon;
  final Color color;

  const FormTransactionType({
    required this.label,
    required this.icon,
    required this.color,
  });

  String get translatedLabel => label.tr;
}

class FormTypeToggle extends StatelessWidget {
  final FormTransactionType selectedType;
  final bool enabled;
  final ValueChanged<FormTransactionType> onTypeSelected;

  const FormTypeToggle({
    super.key,
    required this.selectedType,
    this.enabled = true,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: FormTransactionType.values.map((type) {
          final isSelected = type == selectedType;
          return Expanded(
            child: _TypeButton(
              type: type,
              isSelected: isSelected,
              isEnabled: enabled,
              onTap: enabled ? () => onTypeSelected(type) : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Type button
// ─────────────────────────────────────────────────────────────────────────────

class _TypeButton extends StatelessWidget {
  final FormTransactionType type;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback? onTap;

  const _TypeButton({
    required this.type,
    required this.isSelected,
    required this.isEnabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled
          ? () {
              _logger.debug(
                'Transaction type changed to: ${type.label}',
                tag: 'FormTypeToggle',
              );
              onTap?.call();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? type.color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              type.icon,
              color: isSelected ? type.color : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              type.translatedLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected ? type.color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
