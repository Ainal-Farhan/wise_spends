// FIXED: Extracted from budget_list_screen.dart to reduce file size
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_state.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Budget filter chip row widget
class BudgetFilterChipRow extends StatelessWidget {
  final BudgetState state;
  final void Function(BudgetPeriod?) onFilterSelected;

  const BudgetFilterChipRow({
    super.key,
    required this.state,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    final current = state is BudgetsLoaded
        ? (state as BudgetsLoaded).filterPeriod
        : null;

    const periods = <BudgetPeriod?>[
      null,
      BudgetPeriod.daily,
      BudgetPeriod.weekly,
      BudgetPeriod.monthly,
      BudgetPeriod.yearly,
    ];

    final labels = [
      'budgets.period_all'.tr,
      'budgets.period_day'.tr,
      'budgets.period_week'.tr,
      'budgets.period_month'.tr,
      'budgets.period_year'.tr,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(periods.length, (i) {
          final selected = current == periods[i];
          return Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : AppSpacing.xs),
            child: FilterChip(
              label: Text(labels[i]),
              selected: selected,
              onSelected: (_) {
                final next = selected ? null : periods[i];
                onFilterSelected(next);
              },
              selectedColor: AppColors.tertiary.withValues(alpha: 0.2),
              checkmarkColor: AppColors.tertiary,
              labelStyle: AppTextStyles.labelSmall.copyWith(
                color: selected ? AppColors.tertiary : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }),
      ),
    );
  }
}
