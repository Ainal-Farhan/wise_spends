// FIXED: Extracted from add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Category selector chip widget
class CategorySelectorChip extends StatelessWidget {
  final CategoryEntity? selectedCategory;
  final VoidCallback onTap;

  const CategorySelectorChip({
    super.key,
    required this.selectedCategory,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selectedCategory != null
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedCategory != null
                ? AppColors.primary
                : AppColors.divider,
            width: selectedCategory != null ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedCategory != null
                  ? CategoryIconMapper.getIconForCategory(
                      selectedCategory!.name,
                    )
                  : Icons.category_outlined,
              color: selectedCategory != null
                  ? AppColors.primary
                  : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              selectedCategory?.name ?? 'Select category',
              style: AppTextStyles.bodyMedium.copyWith(
                color: selectedCategory != null
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: selectedCategory != null
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Date picker button widget
class DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;

  const DatePickerButton({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              Icons.calendar_today,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Time picker button widget
class TimePickerButton extends StatelessWidget {
  final String label;
  final TimeOfDay? selectedTime;
  final VoidCallback onTap;

  const TimePickerButton({
    super.key,
    required this.label,
    required this.selectedTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              Icons.access_time,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    selectedTime?.format(context) ?? '',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
