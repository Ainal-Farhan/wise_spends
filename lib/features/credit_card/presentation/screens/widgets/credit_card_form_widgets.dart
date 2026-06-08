import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// ── drag handle ────────────────────────────────────────────────────────────────

class CcDragHandle extends StatelessWidget {
  const CcDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
      ),
    );
  }
}

// ── day picker field ───────────────────────────────────────────────────────────

class CcDayPickerField extends StatelessWidget {
  final String label;
  final String hint;
  final int value;
  final void Function(int) onChanged;

  const CcDayPickerField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _showDayPicker(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    hint.trWith({'day': value.toString()}),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                value.toString(),
                style: AppTextStyles.bodyLarge.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDayPicker(BuildContext context) {
    showModalBottomSheet(
      showDragHandle: false,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (ctx) => CcDayPickerSheet(
        title: label,
        selected: value,
        onSelected: (d) {
          onChanged(d);
          Navigator.pop(ctx);
        },
      ),
    );
  }
}

class CcDayPickerSheet extends StatelessWidget {
  final String title;
  final int selected;
  final void Function(int) onSelected;

  const CcDayPickerSheet({
    super.key,
    required this.title,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CcDragHandle(),
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'credit_card.day_picker_hint'.tr,
            style: AppTextStyles.bodySmall.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: 31,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isSelected = day == selected;
              return GestureDetector(
                onTap: () => onSelected(day),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary : cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      day.toString(),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: isSelected ? cs.onPrimary : cs.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ── billing cycle preview ──────────────────────────────────────────────────────

class CcBillingCyclePreview extends StatelessWidget {
  final int statementDay;
  final int dueDay;

  const CcBillingCyclePreview({
    super.key,
    required this.statementDay,
    required this.dueDay,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: cs.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'credit_card.billing_cycle_preview'.trWith({
                'stmt': statementDay.toString(),
                'due': dueDay.toString(),
              }),
              style: AppTextStyles.caption.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ── last 4 digits field ────────────────────────────────────────────────────────

class CcLast4Field extends StatelessWidget {
  final TextEditingController controller;

  const CcLast4Field({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'credit_card.field_last4'.tr,
        counterText: '',
        border: const OutlineInputBorder(),
        prefixText: '•••• ',
      ),
    );
  }
}
