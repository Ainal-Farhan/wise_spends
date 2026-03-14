// transaction_filter_widgets.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Transaction type filter dropdown for the history screen
class TransactionFilterDropdown extends StatelessWidget {
  final TransactionType? selectedType;
  final void Function(TransactionType?) onTypeSelected;

  const TransactionFilterDropdown({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: selectedType != null
            ? selectedType!.color.withValues(alpha: 0.07)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedType != null
              ? selectedType!.color.withValues(alpha: 0.3)
              : AppColors.divider,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: DropdownButton<TransactionType?>(
        value: selectedType,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: Icon(
          Icons.tune_rounded,
          size: 18,
          color: selectedType != null
              ? selectedType!.color
              : AppColors.textSecondary,
        ),
        hint: Row(
          children: [
            Icon(
              Icons.all_inclusive_rounded,
              size: 17,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              'transaction.filter.all_types'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        items: [
          DropdownMenuItem<TransactionType?>(
            value: null,
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: const Icon(
                    Icons.all_inclusive_rounded,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Text('transaction.filter.all_types'.tr),
              ],
            ),
          ),
          ...TransactionType.values.map(
            (type) => DropdownMenuItem<TransactionType?>(
              value: type,
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: type.color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(type.icon, size: 14, color: type.color),
                  ),
                  const SizedBox(width: 10),
                  Text(type.label),
                ],
              ),
            ),
          ),
        ],
        selectedItemBuilder: (context) => [
          // "All types" selected item
          Row(
            children: [
              const Icon(
                Icons.all_inclusive_rounded,
                size: 17,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'transaction.filter.all_types'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          ...TransactionType.values.map(
            (type) => Row(
              children: [
                Icon(type.icon, size: 17, color: type.color),
                const SizedBox(width: 8),
                Text(
                  type.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: type.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        onChanged: onTypeSelected,
      ),
    );
  }
}

/// Pill-shaped chip for active filters
class ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;
  final IconData? icon;

  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.color,
    required this.onRemove,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 6, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 11, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

/// Date range option chip (used in filter bottom sheet)
class DateRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DateRangeChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Filter option list tile (used in filter bottom sheet)
class FilterOptionTile extends StatelessWidget {
  final String label;
  final TransactionType? type;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterOptionTile({
    super.key,
    required this.label,
    required this.type,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? color.withValues(alpha: 0.07)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? color.withValues(alpha: 0.2)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? color : AppColors.textPrimary,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 160),
                child: isSelected
                    ? Icon(
                        Icons.check_circle_rounded,
                        color: color,
                        key: const ValueKey('check'),
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textSecondary,
                        key: const ValueKey('arrow'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
