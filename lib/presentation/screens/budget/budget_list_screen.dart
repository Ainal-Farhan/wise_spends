import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/entities/budget/budget_entity.dart';
import 'package:wise_spends/data/repositories/budget/i_budget_repository.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_event.dart';
import 'package:wise_spends/presentation/blocs/budget/budget_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';

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
        title: Text('budgets.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterBottomSheet(context),
            tooltip: 'general.filter'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<BudgetBloc>().add(RefreshBudgetsEvent()),
        child: CustomScrollView(
          slivers: [
            // ── Header card (replaces old gradient container) ──────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _buildHeaderCard(context),
              ),
            ),

            // ── Filter chips with SectionHeaderCompact label ───────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.xs,
                ),
                child: SectionHeaderCompact(
                  title: 'budgets.filter_by_period'.tr,
                  trailing: _buildFilterChipRow(context),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

            // ── Budget list ────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: BlocBuilder<BudgetBloc, BudgetState>(
                builder: (context, state) {
                  if (state is BudgetLoading) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, _) => const ShimmerBudgetCard(),
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
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, index) =>
                            _buildBudgetCard(context, state.budgets[index]),
                        childCount: state.budgets.length,
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
                          onAction: () => context.read<BudgetBloc>().add(
                            LoadBudgetsEvent(),
                          ),
                        ),
                      ),
                    );
                  }
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                },
              ),
            ),

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

  // ---------------------------------------------------------------------------
  // Header card — SectionHeader.card
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        if (state is! BudgetsLoaded) return const ShimmerBudgetCard();

        final total = state.budgets.length;
        final onTrack = state.onTrackCount;
        final pct = total > 0 ? (onTrack / total * 100).toInt() : 0;

        return SectionHeader.card(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.tertiary, AppColors.tertiaryDark],
          ),
          icon: Icons.pie_chart_outline,
          label: 'budgets.title'.tr,
          title:
              '$onTrack of $total ${'budgets.title'.tr.toLowerCase()} on track',
          subtitle: '$pct% success rate',
          learnMoreLabel: 'general.learn_more'.tr,
          learnLessLabel: 'general.less'.tr,
          collapsibleBody: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeaderBullet('budgets.tip_categories'.tr),
              SectionHeaderBullet('budgets.tip_period'.tr),
              SectionHeaderBullet('budgets.tip_alert'.tr),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Horizontal filter chips (used inside SectionHeaderCompact trailing)
  // ---------------------------------------------------------------------------

  Widget _buildFilterChipRow(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        BudgetPeriod? current;
        if (state is BudgetsLoaded) current = state.filterPeriod;

        final periods = <BudgetPeriod?>[
          null,
          BudgetPeriod.daily,
          BudgetPeriod.weekly,
          BudgetPeriod.monthly,
          BudgetPeriod.yearly,
        ];
        final labels = ['All', 'Day', 'Week', 'Month', 'Year'];

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
                  onSelected: (_) => context.read<BudgetBloc>().add(
                    FilterBudgetsByPeriodEvent(selected ? null : periods[i]),
                  ),
                  selectedColor: AppColors.tertiary.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.tertiary,
                  labelStyle: AppTextStyles.labelSmall.copyWith(
                    color: selected
                        ? AppColors.tertiary
                        : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildBudgetCard(BuildContext context, dynamic budget) {
    final spentAmount = budget.spentAmount as double? ?? 0.0;
    final budgetAmount = budget.amount as double? ?? 1.0;
    final progress = spentAmount / budgetAmount;
    final progressColor = AppColors.getBudgetProgressColor(progress);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ───────────────────────────────────────────────────
          Row(
            children: [
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
                      '${budget.categoryName ?? 'Category'} · ${_formatPeriod(budget.period)}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Inline percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${(progress.clamp(0.0, 1.0) * 100).toInt()}%',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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

          // ── Progress bar ─────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: progressColor.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Amount row with SectionHeaderCompact ─────────────────────────
          SectionHeaderCompact(
            title: NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 2,
            ).format(spentAmount),
            trailing: Text(
              'of ${NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(budgetAmount)}',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
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
      default:
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
              title: Text('budgets.edit_budget'.tr),
              onTap: () {
                Navigator.pop(context);
                _showEditBudgetDialog(context, budget);
              },
            ),
            ListTile(
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
              title: Text(
                'general.delete'.tr,
                style: const TextStyle(color: AppColors.secondary),
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
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete Budget?',
          message:
              'Are you sure you want to delete "${budget.name}"? This cannot be undone.',
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.delete'.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BudgetBloc>().add(
                  DeleteBudgetEvent(budget.id.toString()),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('budgets.delete_success'.tr),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditBudgetDialog(BuildContext context, dynamic budget) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budgets.edit_coming_soon'.tr),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCreateBudgetDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budgets.create_coming_soon'.tr),
        behavior: SnackBarBehavior.floating,
      ),
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
            SectionHeader(
              title: 'budgets.filter_by_period'.tr,
              showDivider: true,
            ),
            const SizedBox(height: AppSpacing.md),
            _buildFilterOption(label: 'All Periods', period: null),
            _buildFilterOption(label: 'Daily', period: BudgetPeriod.daily),
            _buildFilterOption(label: 'Weekly', period: BudgetPeriod.weekly),
            _buildFilterOption(label: 'Monthly', period: BudgetPeriod.monthly),
            _buildFilterOption(label: 'Yearly', period: BudgetPeriod.yearly),
            const SizedBox(height: AppSpacing.lg),
            AppButton.secondary(
              label: 'general.clear'.tr,
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
        BudgetPeriod? current;
        if (state is BudgetsLoaded) current = state.filterPeriod;
        final isSelected = current == period;

        return ListTile(
          leading: Icon(
            isSelected
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: AppColors.tertiary,
          ),
          title: Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.tertiary : null,
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
