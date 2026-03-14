// FIXED: Extracted from add_edit_budget_plan_item_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Tag chip widget for displaying selected tags
class BudgetPlanTagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const BudgetPlanTagChip({
    super.key,
    required this.tag,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 10,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tags section with add/remove functionality
class BudgetPlanTagsSection extends StatelessWidget {
  final Set<String> selectedTags;
  final bool showTagPicker;
  final VoidCallback onTogglePicker;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onPickerClose;

  const BudgetPlanTagsSection({
    super.key,
    required this.selectedTags,
    required this.showTagPicker,
    required this.onTogglePicker,
    required this.onTagRemoved,
    required this.onTagsChanged,
    required this.onPickerClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            ...selectedTags.map(
              (tag) => BudgetPlanTagChip(
                tag: tag,
                onRemove: () => onTagRemoved(tag),
              ),
            ),
            GestureDetector(
              onTap: onTogglePicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: showTagPicker
                      ? Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: showTagPicker
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showTagPicker ? Icons.close : Icons.add,
                      size: 12,
                      color: showTagPicker
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      showTagPicker
                          ? 'general.close'.tr
                          : 'budget_plans.add_tags'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: showTagPicker
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showTagPicker) ...[
          const SizedBox(height: AppSpacing.sm),
          // TagPicker widget would go here - kept inline due to stateful nature
        ],
      ],
    );
  }
}
