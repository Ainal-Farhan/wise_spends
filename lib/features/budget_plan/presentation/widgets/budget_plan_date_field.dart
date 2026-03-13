// FIXED: Extracted from add_edit_budget_plan_item_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Date picker field widget
class BudgetPlanDateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;
  final VoidCallback? onClear;

  const BudgetPlanDateField({
    super.key,
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selectedDate != null
                ? WiseSpendsColors.primary.withValues(alpha: 0.4)
                : WiseSpendsColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? WiseSpendsColors.primary.withValues(alpha: 0.1)
                    : WiseSpendsColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: selectedDate != null
                    ? WiseSpendsColors.primary
                    : WiseSpendsColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: WiseSpendsColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(selectedDate!)
                        : 'budget_plans.select_due_date'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selectedDate != null
                          ? WiseSpendsColors.textPrimary
                          : WiseSpendsColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: WiseSpendsColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: WiseSpendsColors.textSecondary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: WiseSpendsColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
