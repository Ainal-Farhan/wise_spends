import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';
import 'package:wise_spends/data/repositories/budget/i_budget_repository.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_event.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Budget List Screen
/// Features:
/// - Budget summary card at top
/// - Budget cards with progress indicators
/// - Color-coded progress (green/amber/red)
/// - Filter chips by period
/// - Pull-to-refresh
/// - Empty state with CTA
class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          BudgetBloc(context.read<IBudgetRepository>())
            ..add(LoadBudgetsEvent()),
      child: const _BudgetListScreenContent(),
    );
  }
}

class _BudgetListScreenContent extends StatefulWidget {
  const _BudgetListScreenContent();

  @override
  State<_BudgetListScreenContent> createState() =>
      _BudgetListScreenContentState();
}

class _BudgetListScreenContentState extends State<_BudgetListScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'Filter',
            constraints: const BoxConstraints(
              minWidth: AppTouchTarget.min,
              minHeight: AppTouchTarget.min,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<BudgetBloc>().add(RefreshBudgetsEvent());
        },
        child: CustomScrollView(
          slivers: [
            // Summary card
            SliverToBoxAdapter(child: _buildSummaryCard(context)),

            // Filter chips
            SliverToBoxAdapter(child: _buildFilterChips(context)),

            // Budget list
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoading) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ShimmerBudgetCard(),
                        childCount: 3,
                      ),
                    );
                  } else if (state is BudgetsLoaded) {
                    if (state.budgets.isEmpty) {
                      return SliverToBoxAdapter(
                        child: NoBudgetsEmptyState(
                          onAddBudget: () => _showCreateBudgetDialog(context),
                        ),
                      );
                    }

                    // Budgets are already filtered by BLoC
                    final budgets = state.budgets;

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            _buildBudgetCard(context, budgets[index]),
                        childCount: budgets.length,
                      ),
                    );
                  } else if (state is BudgetEmpty) {
                    return SliverToBoxAdapter(
                      child: NoBudgetsEmptyState(
                        onAddBudget: () => _showCreateBudgetDialog(context),
                      ),
                    );
                  } else if (state is BudgetError) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.xxxl),
                        child: ErrorStateWidget(
                          message: state.message,
                          onAction: () {
                            context.read<BudgetBloc>().add(LoadBudgetsEvent());
                          },
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ),

            // Bottom padding for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBudgetDialog(context),
        elevation: AppElevation.sm,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state is BudgetsLoaded) {
          final totalBudgets = state.budgets.length;
          final onTrack = state.onTrackCount;
          final percentage = totalBudgets > 0
              ? (onTrack / totalBudgets * 100).toInt()
              : 0;

          return Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.tertiary, AppColors.tertiaryDark],
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.tertiary.withValues(alpha: 0.3),
                  blurRadius: AppElevation.lg,
                  offset: const Offset(0, AppElevation.sm),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: Colors.white,
                  size: AppIconSize.xl,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '$onTrack of $totalBudgets budgets on track',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '$percentage% success rate',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        }
        return const ShimmerBudgetCard();
      },
    );
  }

  Widget _buildBudgetCard(BuildContext context, dynamic budget) {
    // Calculate progress percentage
    final spentAmount = budget.spentAmount as double? ?? 0.0;
    final budgetAmount = budget.amount as double? ?? 1.0;
    final progress = spentAmount / budgetAmount;
    final progressColor = AppColors.getBudgetProgressColor(progress);

    return AppCard(
      onTap: () {
        // Navigate to budget detail
        // AppRouter.navigateTo(
        //   context,
        //   AppRoutes.budgetDetail,
        //   arguments: BudgetDetailArgs(budget.id),
        // );
      },
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Category icon
              Container(
                width: AppTouchTarget.min,
                height: AppTouchTarget.min,
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: progressColor,
                  size: AppIconSize.lg,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.name.toString(),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${budget.categoryName ?? 'Category'} • ${_formatPeriod(budget.period)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // More options button
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () => _showBudgetOptions(context, budget),
                constraints: const BoxConstraints(
                  minWidth: AppTouchTarget.min,
                  minHeight: AppTouchTarget.min,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: progressColor.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          // Amount text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AmountText.small(
                amount: spentAmount,
                type: spentAmount > budgetAmount * 0.85
                    ? AmountType.expense
                    : AmountType.neutral,
              ),
              Text(
                'of ${NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(budgetAmount)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPeriod(BudgetPeriod? period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'Daily';
      case BudgetPeriod.weekly:
        return 'Weekly';
      case BudgetPeriod.monthly:
        return 'Monthly';
      case BudgetPeriod.yearly:
        return 'Yearly';
      case null:
        return 'One-time';
    }
  }

  void _showBudgetOptions(BuildContext context, dynamic budget) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            ListTile(
              minLeadingWidth: AppTouchTarget.min,
              leading: Container(
                width: AppTouchTarget.min,
                height: AppTouchTarget.min,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Edit Budget'),
              onTap: () {
                Navigator.pop(context);
                _showEditBudgetDialog(context, budget);
              },
            ),
            ListTile(
              minLeadingWidth: AppTouchTarget.min,
              leading: Container(
                width: AppTouchTarget.min,
                height: AppTouchTarget.min,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.secondary,
                ),
              ),
              title: const Text(
                'Delete Budget',
                style: TextStyle(color: AppColors.secondary),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteBudget(context, budget);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteBudget(BuildContext context, dynamic budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
        ),
        actions: [
          AppButton.text(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.destructive(
            label: 'Delete',
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetBloc>().add(
                DeleteBudgetEvent(budget.id.toString()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Budget deleted successfully'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, dynamic budget) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edit budget feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateBudgetDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create budget feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(label: 'All', period: null),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(label: 'Daily', period: BudgetPeriod.daily),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(label: 'Weekly', period: BudgetPeriod.weekly),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(label: 'Monthly', period: BudgetPeriod.monthly),
            const SizedBox(width: AppSpacing.sm),
            _buildFilterChip(label: 'Yearly', period: BudgetPeriod.yearly),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required BudgetPeriod? period,
  }) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        BudgetPeriod? currentFilterPeriod;
        if (state is BudgetsLoaded) {
          currentFilterPeriod = state.filterPeriod;
        }

        final isSelected = currentFilterPeriod == period;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            context.read<BudgetBloc>().add(
              FilterBudgetsByPeriodEvent(selected ? period : null),
            );
          },
          selectedColor: AppColors.primary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.primary,
        );
      },
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xxl),
          ),
        ),
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Filter by Period', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            _buildFilterOption(label: 'All Periods', period: null),
            _buildFilterOption(label: 'Daily', period: BudgetPeriod.daily),
            _buildFilterOption(label: 'Weekly', period: BudgetPeriod.weekly),
            _buildFilterOption(label: 'Monthly', period: BudgetPeriod.monthly),
            _buildFilterOption(label: 'Yearly', period: BudgetPeriod.yearly),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: 'Clear Filter',
              onPressed: () {
                context.read<BudgetBloc>().add(ClearBudgetFiltersEvent());
                Navigator.pop(context);
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String label,
    required BudgetPeriod? period,
  }) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        BudgetPeriod? currentFilterPeriod;
        if (state is BudgetsLoaded) {
          currentFilterPeriod = state.filterPeriod;
        }

        final isSelected = currentFilterPeriod == period;

        return ListTile(
          minLeadingWidth: AppTouchTarget.min,
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: AppColors.primary,
          ),
          title: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          onTap: () {
            context.read<BudgetBloc>().add(FilterBudgetsByPeriodEvent(period));
            Navigator.pop(context);
          },
        );
      },
    );
  }
}
