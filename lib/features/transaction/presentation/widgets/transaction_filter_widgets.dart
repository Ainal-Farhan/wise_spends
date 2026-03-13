// FIXED: Extracted from transaction_history_screen.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Filter dropdown widget for transaction type selection
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
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: DropdownButton<TransactionType?>(
        value: selectedType,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.filter_list, size: 20),
        style: AppTextStyles.bodyMedium.copyWith(
          color: WiseSpendsColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        hint: Row(
          children: [
            Icon(
              Icons.all_inclusive,
              size: 18,
              color: WiseSpendsColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'All Types',
              style: AppTextStyles.bodyMedium.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
        items: [
          DropdownMenuItem<TransactionType?>(
            value: null,
            child: Row(
              children: [
                Icon(
                  Icons.all_inclusive,
                  size: 18,
                  color: WiseSpendsColors.textSecondary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('All Types'),
              ],
            ),
          ),
          ...TransactionType.values.map(
            (type) => DropdownMenuItem<TransactionType?>(
              value: type,
              child: Row(
                children: [
                  Icon(type.icon, size: 18, color: type.color),
                  const SizedBox(width: AppSpacing.sm),
                  Text(type.label),
                ],
              ),
            ),
          ),
        ],
        onChanged: onTypeSelected,
      ),
    );
  }
}

/// Active filter chip widget
class ActiveFilterChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onRemove;

  const ActiveFilterChip({
    super.key,
    required this.label,
    required this.color,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_list,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 10,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
