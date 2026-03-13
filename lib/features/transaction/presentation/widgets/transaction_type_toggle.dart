// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Transaction type toggle widget
class TransactionTypeToggle extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onTypeSelected;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'transactions.type'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                icon: Icons.arrow_upward,
                label: 'transactions.income'.tr,
                isSelected: selectedType == TransactionType.income,
                color: AppColors.income,
                onTap: () => onTypeSelected(TransactionType.income),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TypeButton(
                icon: Icons.arrow_downward,
                label: 'transactions.expense'.tr,
                isSelected: selectedType == TransactionType.expense,
                color: AppColors.expense,
                onTap: () => onTypeSelected(TransactionType.expense),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _TypeButton(
                icon: Icons.swap_horiz,
                label: 'transactions.transfer'.tr,
                isSelected: selectedType == TransactionType.transfer,
                color: AppColors.transfer,
                onTap: () => onTypeSelected(TransactionType.transfer),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected ? color : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
