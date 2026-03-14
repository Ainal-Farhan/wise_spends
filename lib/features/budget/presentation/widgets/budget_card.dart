// FIXED: Extracted from budget_list_screen.dart to reduce file size
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_event.dart';
import 'package:wise_spends/features/budget/presentation/screens/edit_budget_sheet.dart';
import 'package:wise_spends/features/budget/presentation/widgets/budget_options_sheet.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/shared/components/app_card.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'budget_category_icon.dart';
import 'percentage_badge.dart';

/// Budget card widget - displays individual budget item
class BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final String? categoryName;

  const BudgetCard({super.key, required this.budget, this.categoryName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final spentAmount = budget.spentAmount;
    final budgetAmount = budget.limitAmount.clamp(0.01, double.infinity);
    final progress = (spentAmount / budgetAmount).clamp(0.0, 1.0);
    final progressColor = progress < 0.6 
        ? colorScheme.primary 
        : progress < 0.85 
            ? colorScheme.tertiary 
            : colorScheme.secondary;
    final currencyFmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    final isInactive = !budget.isActive;

    return Opacity(
      opacity: isInactive ? 0.55 : 1.0,
      child: AppCard(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        onTap: () {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const BudgetCategoryIcon(),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          if (categoryName != null) ...[
                            Flexible(
                              child: Text(
                                categoryName!,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '·',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                            child: Text(
                              _formatPeriod(budget.period),
                              style: AppTextStyles.captionSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                PercentageBadge(progress: progress, color: progressColor),
                SizedBox(
                  width: AppTouchTarget.min,
                  height: AppTouchTarget.min,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showBudgetOptions(context),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Amount summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFmt.format(spentAmount),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'of ${currencyFmt.format(budgetAmount)}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showBudgetOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<BudgetBloc>()),
          BlocProvider.value(value: context.read<CategoryBloc>()),
        ],
        child: BudgetOptionsSheet(
          budget: budget,
          onEdit: () {
            Navigator.pop(context);
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (_) => MultiBlocProvider(
                providers: [
                  BlocProvider.value(value: context.read<BudgetBloc>()),
                  BlocProvider.value(value: context.read<CategoryBloc>()),
                ],
                child: EditBudgetSheet(budget: budget),
              ),
            );
          },
          onToggleActive: () {
            Navigator.pop(context);
            context.read<BudgetBloc>().add(
              ToggleBudgetActiveEvent(
                budgetId: budget.id,
                isActive: !budget.isActive,
              ),
            );
          },
          onDelete: () {
            Navigator.pop(context);
            context.read<BudgetBloc>().add(DeleteBudgetEvent(budget.id));
          },
        ),
      ),
    );
  }

  String _formatPeriod(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'budgets.period_daily'.tr;
      case BudgetPeriod.weekly:
        return 'budgets.period_weekly'.tr;
      case BudgetPeriod.monthly:
        return 'budgets.period_monthly'.tr;
      case BudgetPeriod.yearly:
        return 'budgets.period_yearly'.tr;
    }
  }
}
