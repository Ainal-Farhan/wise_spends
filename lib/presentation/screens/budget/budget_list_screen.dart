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

class _BudgetListScreenContent extends StatelessWidget {
  const _BudgetListScreenContent();

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
        child: BlocBuilder<BudgetBloc, BudgetState>(
          builder: (context, state) => CustomScrollView(
            slivers: [
              // ── Header card ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: _BudgetHeaderCard(state: state),
                ),
              ),

              // ── Filter section ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: SectionHeaderCompact(
                    title: 'budgets.filter_by_period'.tr,
                    trailing: _BudgetFilterChipRow(),
                  ),
                ),
              ),

              // ── Budget list ───────────────────────────────────────────────
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
                    }
                    if (state is BudgetsLoaded) {
                      if (state.budgets.isEmpty) {
                        return SliverToBoxAdapter(
                          child: NoBudgetsEmptyState(
                            onAddBudget: () => _showCreateBudgetDialog(context),
                          ),
                        );
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _BudgetCard(budget: state.budgets[i]),
                          childCount: state.budgets.length,
                        ),
                      );
                    }
                    if (state is BudgetEmpty) {
                      return SliverToBoxAdapter(
                        child: NoBudgetsEmptyState(
                          onAddBudget: () => _showCreateBudgetDialog(context),
                        ),
                      );
                    }
                    if (state is BudgetError) {
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

              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBudgetDialog(context),
        elevation: AppElevation.sm,
        tooltip: 'budgets.create'.tr,
        child: const Icon(Icons.add),
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
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: _BudgetFilterBottomSheet(),
      ),
    );
  }
}

// =============================================================================
// Header card
// =============================================================================

class _BudgetHeaderCard extends StatelessWidget {
  final BudgetState state;

  const _BudgetHeaderCard({required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is! BudgetsLoaded) return const ShimmerBudgetCard();

    final loaded = state as BudgetsLoaded;
    final total = loaded.budgets.length;
    final onTrack = loaded.onTrackCount;
    final pct = total > 0 ? (onTrack / total * 100).toInt() : 0;

    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.tertiary, AppColors.tertiaryDark],
      ),
      icon: Icons.pie_chart_outline,
      label: 'budgets.title'.tr,
      title: '$onTrack / $total ${'budgets.on_track_label'.tr}',
      subtitle: '$pct% ${'budgets.success_rate'.tr}',
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
  }
}

// =============================================================================
// Filter chip row (extracted so it can read BudgetBloc independently)
// =============================================================================

class _BudgetFilterChipRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        final current = state is BudgetsLoaded ? state.filterPeriod : null;

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
}

// =============================================================================
// Budget card
// =============================================================================

class _BudgetCard extends StatelessWidget {
  final dynamic budget;

  const _BudgetCard({required this.budget});

  @override
  Widget build(BuildContext context) {
    final spentAmount = (budget.spentAmount as double?) ?? 0.0;
    final budgetAmount = ((budget.amount as double?) ?? 1.0).clamp(
      0.01,
      double.infinity,
    );
    final progress = (spentAmount / budgetAmount).clamp(0.0, 1.0);
    final progressColor = AppColors.getBudgetProgressColor(progress);
    final currencyFmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          Row(
            children: [
              _CategoryIcon(color: progressColor),
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
              // Percentage badge
              _PercentageBadge(progress: progress, color: progressColor),
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

          // ── Progress bar ──────────────────────────────────────────────────
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

          // ── Amount summary ────────────────────────────────────────────────
          SectionHeaderCompact(
            title: currencyFmt.format(spentAmount),
            trailing: Text(
              '${'budgets.of'.tr} ${currencyFmt.format(budgetAmount)}',
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
        return 'budgets.period_daily'.tr;
      case BudgetPeriod.weekly:
        return 'budgets.period_weekly'.tr;
      case BudgetPeriod.monthly:
        return 'budgets.period_monthly'.tr;
      case BudgetPeriod.yearly:
        return 'budgets.period_yearly'.tr;
      default:
        return 'budgets.period_one_time'.tr;
    }
  }

  void _showBudgetOptions(BuildContext context, dynamic budget) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _BudgetOptionsSheet(budget: budget),
    );
  }
}

// =============================================================================
// Small reusable pieces
// =============================================================================

class _CategoryIcon extends StatelessWidget {
  final Color color;

  const _CategoryIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTouchTarget.min,
      height: AppTouchTarget.min,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(
        Icons.shopping_bag_outlined,
        color: color,
        size: AppIconSize.lg,
      ),
    );
  }
}

class _PercentageBadge extends StatelessWidget {
  final double progress;
  final Color color;

  const _PercentageBadge({required this.progress, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        '${(progress * 100).toInt()}%',
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// =============================================================================
// Budget options bottom sheet
// =============================================================================

class _BudgetOptionsSheet extends StatelessWidget {
  final dynamic budget;

  const _BudgetOptionsSheet({required this.budget});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          // Handle
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
          SectionHeader(title: budget.name.toString(), showDivider: true),
          const SizedBox(height: AppSpacing.md),
          ListTile(
            leading: Container(
              width: AppTouchTarget.min,
              height: AppTouchTarget.min,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(Icons.edit_outlined, color: AppColors.primary),
            ),
            title: Text('budgets.edit_budget'.tr),
            onTap: () {
              Navigator.pop(context);
              _showEditSnack(context);
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
              _confirmDelete(context, budget);
            },
          ),
        ],
      ),
    );
  }

  void _showEditSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budgets.edit_coming_soon'.tr),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _confirmDelete(BuildContext context, dynamic budget) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'budgets.delete_title'.tr,
          message: 'budgets.delete_confirm'.trWith({
            'name': budget.name.toString(),
          }),
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
}

// =============================================================================
// Filter bottom sheet
// =============================================================================

class _BudgetFilterBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
          _buildOption(context, label: 'budgets.period_all'.tr, period: null),
          _buildOption(
            context,
            label: 'budgets.period_daily'.tr,
            period: BudgetPeriod.daily,
          ),
          _buildOption(
            context,
            label: 'budgets.period_weekly'.tr,
            period: BudgetPeriod.weekly,
          ),
          _buildOption(
            context,
            label: 'budgets.period_monthly'.tr,
            period: BudgetPeriod.monthly,
          ),
          _buildOption(
            context,
            label: 'budgets.period_yearly'.tr,
            period: BudgetPeriod.yearly,
          ),
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
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required BudgetPeriod? period,
  }) {
    return BlocBuilder<BudgetBloc, BudgetState>(
      builder: (context, state) {
        final current = state is BudgetsLoaded ? state.filterPeriod : null;
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
