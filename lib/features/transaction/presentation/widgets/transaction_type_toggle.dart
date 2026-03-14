// transaction_type_toggle.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Animated transaction type toggle — income / expense / transfer
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
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _ToggleTab(
            type: TransactionType.income,
            label: 'transaction.type.income'.tr,
            icon: Icons.arrow_downward_rounded,
            color: AppColors.income,
            isSelected: selectedType == TransactionType.income,
            onTap: () => onTypeSelected(TransactionType.income),
          ),
          _ToggleTab(
            type: TransactionType.expense,
            label: 'transaction.type.expense'.tr,
            icon: Icons.arrow_upward_rounded,
            color: AppColors.expense,
            isSelected: selectedType == TransactionType.expense,
            onTap: () => onTypeSelected(TransactionType.expense),
          ),
          _ToggleTab(
            type: TransactionType.transfer,
            label: 'transaction.type.transfer'.tr,
            icon: Icons.swap_horiz_rounded,
            color: AppColors.transfer,
            isSelected: selectedType == TransactionType.transfer,
            onTap: () => onTypeSelected(TransactionType.transfer),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final TransactionType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
