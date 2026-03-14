// FIXED: Extracted from budget_plans_forms.dart to reduce file size
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'budget_plan_form_data.dart';
import 'budget_plan_form_widgets.dart';

/// Step 1: Basics - Plan name, description, category, accent color
class StepBasics extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final bool showAccentColor;

  const StepBasics({
    super.key,
    required this.data,
    required this.callbacks,
    required this.nameCtrl,
    required this.descCtrl,
    this.showAccentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StepHeader(
            title: 'budget_plans.step_basics'.tr,
            subtitle: 'budget_plans.step_basics_subtitle'.tr,
            icon: Icons.edit_note_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'budget_plans.plan_name'.tr,
            hint: 'budget_plans.plan_name_hint'.tr,
            controller: nameCtrl,
            onChanged: callbacks.onNameChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'budget_plans.description'.tr,
            hint: 'budget_plans.description_hint'.tr,
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.lg),
          FormSectionLabel(label: 'budget_plans.category'.tr),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: BudgetPlanCategory.values.map((cat) {
              final isSelected = data.category == cat;
              return FilterChip(
                label: Text(cat.displayName),
                selected: isSelected,
                avatar: Text(cat.iconCode),
                onSelected: (_) => callbacks.onCategoryChanged(cat),
                selectedColor: Color(
                  data.accentColorValue,
                ).withValues(alpha: 0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          if (showAccentColor) ...[
            const SizedBox(height: AppSpacing.lg),
            FormSectionLabel(label: 'budget_plans.accent_color'.tr),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _AccentColors.getArgbValues(context).map((colorValue) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: CustomColorSwatch(
                    color: Color(colorValue),
                    isSelected: data.accentColorValue == colorValue,
                    onTap: () => callbacks.onAccentColorChanged(colorValue),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _AccentColors {
  static List<int> getArgbValues(BuildContext context) {
    return [
      Theme.of(context).colorScheme.primary.toARGB32(),
      Theme.of(context).colorScheme.secondary.toARGB32(),
      Theme.of(context).colorScheme.tertiary.toARGB32(),
      Theme.of(context).colorScheme.tertiary.toARGB32(),
      Theme.of(context).colorScheme.primary.toARGB32(),
    ];
  }
}
