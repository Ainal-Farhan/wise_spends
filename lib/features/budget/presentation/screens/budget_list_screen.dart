import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/data/repositories/i_budget_repository.dart';
import 'package:wise_spends/features/category/data/repositories/impl/category_repository.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_event.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';

class BudgetListScreen extends StatelessWidget {
  const BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => BudgetBloc(context.read<IBudgetRepository>())
            ..add(LoadBudgetsEvent())
            ..add(const SyncAllBudgetsSpentAmountEvent()),
        ),
        BlocProvider(
          // CategoryBloc is provided here so every descendant — including
          // the FAB, empty-state button, and the create-budget modal — can
          // access it via context.read<CategoryBloc>() without a
          // ProviderNotFoundException.
          // CategoryRepository self-instantiates its own AppDatabase
          // (same pattern as BudgetRepository), so no external provider needed.
          create: (_) => CategoryBloc(CategoryRepository()),
        ),
      ],
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
      // ── Single top-level BlocBuilder drives the entire body ──────────────
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<BudgetBloc>().add(RefreshBudgetsEvent()),
            child: CustomScrollView(
              slivers: [
                // ── Header card ─────────────────────────────────────────────
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

                // ── Filter chip row ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: _BudgetFilterChipRow(state: state),
                  ),
                ),

                // ── Budget list ─────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  sliver: _buildListSliver(context, state),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.md),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBudgetDialog(context),
        elevation: AppElevation.sm,
        tooltip: 'budgets.create'.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Builds the sliver for the budget list section based on [state].
  Widget _buildListSliver(BuildContext context, BudgetState state) {
    if (state is BudgetLoading || state is BudgetInitial) {
      // Show shimmer skeletons while loading.
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
          (_, i) => _BudgetCard(
            budget: state.budgets[i],
            categoryName: state.categoryNames[state.budgets[i].categoryId],
          ),
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
            onAction: () => context.read<BudgetBloc>().add(LoadBudgetsEvent()),
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }

  void _showCreateBudgetDialog(BuildContext context) {
    // Capture both blocs from the parent context BEFORE the modal opens,
    // then inject them via BlocProvider.value so the new route has access.
    final budgetBloc = context.read<BudgetBloc>();
    final categoryBloc = context.read<CategoryBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (sheetContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: budgetBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: const _CreateBudgetSheet(),
      ),
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: const _BudgetFilterBottomSheet(),
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
    // Show shimmer only while genuinely loading / before first data arrives.
    if (state is BudgetLoading || state is BudgetInitial) {
      return const ShimmerBudgetCard();
    }

    // For error / empty states render a minimal placeholder so the card area
    // doesn't collapse entirely.
    if (state is! BudgetsLoaded) {
      return const SizedBox.shrink();
    }

    final loaded = state as BudgetsLoaded;
    final total = loaded.allBudgets.length; // use allBudgets for true totals
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
// Filter chip row
// Accepts state directly — no nested BlocBuilder needed since the parent
// BlocBuilder already re-renders this widget on every state change.
// =============================================================================

class _BudgetFilterChipRow extends StatelessWidget {
  final BudgetState state;

  const _BudgetFilterChipRow({required this.state});

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
              // Tapping the active chip deselects (shows all).
              // Tapping an inactive chip applies that filter.
              onSelected: (_) {
                final next = selected ? null : periods[i];
                context.read<BudgetBloc>().add(
                  FilterBudgetsByPeriodEvent(next),
                );
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

// =============================================================================
// Budget card
// =============================================================================

class _BudgetCard extends StatelessWidget {
  final BudgetEntity budget;
  final String? categoryName;

  const _BudgetCard({required this.budget, this.categoryName});

  @override
  Widget build(BuildContext context) {
    final spentAmount = budget.spentAmount;
    final budgetAmount = budget.limitAmount.clamp(0.01, double.infinity);
    final progress = (spentAmount / budgetAmount).clamp(0.0, 1.0);
    final progressColor = AppColors.getBudgetProgressColor(progress);
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
            // ── Header ────────────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _BudgetCategoryIcon(color: progressColor),
                const SizedBox(width: AppSpacing.md),
                // Title + category — must be Expanded to avoid overflow
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
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Text(
                              '·',
                              style: TextStyle(color: AppColors.textHint),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              _formatPeriod(budget.period),
                              style: AppTextStyles.captionSmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                // Percentage badge — fixed width so it never pushes siblings
                _PercentageBadge(progress: progress, color: progressColor),
                // Options button — use SizedBox to constrain tappable area
                SizedBox(
                  width: AppTouchTarget.min,
                  height: AppTouchTarget.min,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showBudgetOptions(context, budget),
                    padding: EdgeInsets.zero,
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

            // ── Amount summary ─────────────────────────────────────────────────
            // Use a Row with Expanded children to prevent overflow on long amounts.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    currencyFmt.format(spentAmount),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: Text(
                    '${'budgets.of'.tr} ${currencyFmt.format(budgetAmount)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),

            // ── Date range ───────────────────────────────────────────────────
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: AppIconSize.xs,
                  color: AppColors.textHint,
                ),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    _formatDateRange(budget.startDate, budget.endDate),
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.textHint,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!budget.isActive) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.textHint.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    child: Text(
                      'budgets.status_inactive'.tr,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // ── Remaining / over-budget indicator ─────────────────────────────
            if (budget.isExceeded) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: AppIconSize.sm,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      '${'budgets.over_by'.tr} ${currencyFmt.format(budget.spentAmount - budget.limitAmount)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ] else if (budget.isNearLimit) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppIconSize.sm,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Flexible(
                    child: Text(
                      '${'budgets.remaining'.tr} ${currencyFmt.format(budget.remainingAmount)}',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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

  String _formatDateRange(DateTime start, DateTime? end) {
    final fmt = DateFormat('d MMM yyyy');
    if (end == null) return '${'budgets.date_from'.tr} ${fmt.format(start)}';
    return '${fmt.format(start)} – ${fmt.format(end)}';
  }

  void _showBudgetOptions(BuildContext context, BudgetEntity budget) {
    final budgetBloc = context.read<BudgetBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: budgetBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: _BudgetOptionsSheet(budget: budget),
      ),
    );
  }
}

// =============================================================================
// Small reusable pieces
// =============================================================================

class _BudgetCategoryIcon extends StatelessWidget {
  final Color color;

  const _BudgetCategoryIcon({required this.color});

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
      // Fixed minimum width prevents the badge from shrinking to nothing
      // on low-percentage values (e.g. "3%").
      constraints: const BoxConstraints(minWidth: 44),
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
        textAlign: TextAlign.center,
      ),
    );
  }
}

// =============================================================================
// Budget options bottom sheet
// =============================================================================

class _BudgetOptionsSheet extends StatelessWidget {
  final BudgetEntity budget;

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
          SectionHeader(title: budget.name, showDivider: true),
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
              _showEditSheet(context, budget);
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
          // Safe-area padding for devices with a home indicator
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  void _showEditSheet(BuildContext context, BudgetEntity budget) {
    final budgetBloc = context.read<BudgetBloc>();
    final categoryBloc = context.read<CategoryBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: budgetBloc),
          BlocProvider.value(value: categoryBloc),
        ],
        child: _EditBudgetSheet(budget: budget),
      ),
    );
  }

  void _confirmDelete(BuildContext context, BudgetEntity budget) {
    // Capture bloc before async gap — context may be invalid after await.
    final bloc = context.read<BudgetBloc>();

    showDeleteDialog(
      context: context,
      title: 'budgets.delete_title'.tr,
      message: 'budgets.delete_confirm'.trWith({'name': budget.name}),
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      autoDisplayMessage: false,
      onDelete: () {
        bloc.add(DeleteBudgetEvent(budget.id));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('budgets.delete_success'.tr),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.success,
          ),
        );
      },
    );
  }
}

// =============================================================================
// Filter bottom sheet
// =============================================================================

class _BudgetFilterBottomSheet extends StatelessWidget {
  const _BudgetFilterBottomSheet();

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
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required BudgetPeriod? period,
  }) {
    // Single BlocBuilder here is fine since this is a separate modal context.
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

// =============================================================================
// Create budget bottom sheet
// =============================================================================

class _CreateBudgetSheet extends StatefulWidget {
  const _CreateBudgetSheet();

  @override
  State<_CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<_CreateBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  BudgetPeriod _selectedPeriod = BudgetPeriod.monthly;
  CategoryEntity? _selectedCategory;
  bool _isSubmitting = false;
  bool _categoryError = false;

  DateTime get _startDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? get _endDate {
    final s = _startDate;
    switch (_selectedPeriod) {
      case BudgetPeriod.daily:
        return s.add(const Duration(days: 1));
      case BudgetPeriod.weekly:
        return s.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(s.year, s.month + 1, s.day);
      case BudgetPeriod.yearly:
        return DateTime(s.year + 1, s.month, s.day);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker() async {
    // Capture before the async gap to avoid stale context warnings.
    final categoryBloc = context.read<CategoryBloc>();
    final picked = await showModalBottomSheet<CategoryEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryPickerSheet(selected: _selectedCategory),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedCategory = picked;
        _categoryError = false;
      });
    }
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final categoryValid = _selectedCategory != null;

    setState(() => _categoryError = !categoryValid);

    if (!formValid || !categoryValid) return;

    setState(() => _isSubmitting = true);

    context.read<BudgetBloc>().add(
      CreateBudgetEvent(
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        categoryId: _selectedCategory!.id,
        startDate: _startDate,
        endDate: _endDate,
        period: _selectedPeriod,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Padding(
        // Push the sheet up when the keyboard appears.
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ──────────────────────────────────────────────
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
                const SizedBox(height: AppSpacing.xl),

                // ── Title ────────────────────────────────────────────────────
                Text(
                  'budgets.create'.tr,
                  style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Budget name ──────────────────────────────────────────────
                AppTextField(
                  controller: _nameController,
                  label: 'budgets.field_name'.tr,
                  hint: 'budgets.field_name_hint'.tr,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'budgets.error_name_required'.tr;
                    }
                    if (v.trim().length > 100) {
                      return 'budgets.error_name_too_long'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Limit amount ─────────────────────────────────────────────
                AppTextField(
                  controller: _amountController,
                  label: 'budgets.field_amount'.tr,
                  hint: '0.00',
                  keyboardType: AppTextFieldKeyboardType.currency,
                  textInputAction: TextInputAction.done,
                  prefixText: 'RM ',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'budgets.error_amount_required'.tr;
                    }
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'budgets.error_amount_invalid'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Category picker ──────────────────────────────────────────
                Text(
                  'budgets.field_category'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _categoryError
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _CategoryPickerButton(
                  selected: _selectedCategory,
                  hasError: _categoryError,
                  onTap: _openCategoryPicker,
                ),
                if (_categoryError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'budgets.error_category_required'.tr,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // ── Period picker ────────────────────────────────────────────
                Text(
                  'budgets.field_period'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PeriodSelector(
                  selected: _selectedPeriod,
                  onChanged: (p) => setState(() => _selectedPeriod = p),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Submit button ────────────────────────────────────────────
                AppButton.primary(
                  label: _isSubmitting
                      ? 'general.saving'.tr
                      : 'budgets.create'.tr,
                  onPressed: _isSubmitting ? null : _submit,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Period selector used inside the create form
// =============================================================================

class _PeriodSelector extends StatelessWidget {
  final BudgetPeriod selected;
  final ValueChanged<BudgetPeriod> onChanged;

  const _PeriodSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const periods = BudgetPeriod.values;
    final labels = [
      'budgets.period_daily'.tr,
      'budgets.period_weekly'.tr,
      'budgets.period_monthly'.tr,
      'budgets.period_yearly'.tr,
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: List.generate(periods.length, (i) {
        final isSelected = selected == periods[i];
        return ChoiceChip(
          label: Text(labels[i]),
          selected: isSelected,
          onSelected: (_) => onChanged(periods[i]),
          selectedColor: AppColors.tertiary.withValues(alpha: 0.2),
          checkmarkColor: AppColors.tertiary,
          labelStyle: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? AppColors.tertiary : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          visualDensity: VisualDensity.compact,
        );
      }),
    );
  }
}

// =============================================================================
// Category picker button — tappable row that shows the selected category
// or a placeholder when nothing is chosen yet.
// =============================================================================

class _CategoryPickerButton extends StatelessWidget {
  final CategoryEntity? selected;
  final bool hasError;
  final VoidCallback onTap;

  const _CategoryPickerButton({
    required this.selected,
    required this.hasError,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.error : AppColors.border;
    final borderWidth = hasError ? 1.5 : 1.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.input),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              _CategoryIcon(
                color: AppColors.tertiary,
                iconCodePoint: selected!.iconCodePoint,
                iconFontFamily: selected!.iconFontFamily,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  selected!.name,
                  style: AppTextStyles.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'budgets.field_category_hint'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: AppIconSize.md,
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Category icon — resolves iconCodePoint + iconFontFamily to a real Icon.
// Falls back to a generic icon if the code point can't be parsed.
// =============================================================================

class _CategoryIcon extends StatelessWidget {
  final Color color;
  final String? iconCodePoint;
  final String? iconFontFamily;

  const _CategoryIcon({
    required this.color,
    this.iconCodePoint,
    this.iconFontFamily,
  });

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconData();

    return Container(
      width: AppTouchTarget.min,
      height: AppTouchTarget.min,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(iconData, color: color, size: AppIconSize.lg),
    );
  }

  IconData _getIconData() {
    try {
      return IconData(
        int.parse(iconCodePoint ?? ''),
        fontFamily: iconFontFamily,
        fontPackage: iconFontFamily,
      );
    } catch (_) {
      return Icons.category_outlined;
    }
  }
}

// =============================================================================
// Category picker bottom sheet
// =============================================================================

class _CategoryPickerSheet extends StatefulWidget {
  final CategoryEntity? selected;

  const _CategoryPickerSheet({this.selected});

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  @override
  void initState() {
    super.initState();
    // Safe to dispatch here — context is fully mounted and CategoryBloc
    // has been provided by MultiBlocProvider in _showCreateBudgetDialog.
    context.read<CategoryBloc>().add(LoadExpenseCategoriesEvent());
  }

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
          // Drag handle
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
          const SizedBox(height: AppSpacing.xl),
          SectionHeader(title: 'budgets.field_category'.tr, showDivider: true),
          const SizedBox(height: AppSpacing.md),

          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading || state is CategoryInitial) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final categories = _extractCategories(state);

              if (categories.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                  child: Center(
                    child: Text(
                      'budgets.no_categories'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }

              return ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final cat = categories[i];
                    final isSelected = widget.selected?.id == cat.id;

                    return ListTile(
                      leading: _CategoryIcon(
                        color: AppColors.tertiary,
                        iconCodePoint: cat.iconCodePoint,
                        iconFontFamily: cat.iconFontFamily,
                      ),
                      title: Text(
                        cat.name,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected ? AppColors.tertiary : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.tertiary,
                              size: AppIconSize.md,
                            )
                          : null,
                      onTap: () => Navigator.pop(context, cat),
                    );
                  },
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  List<CategoryEntity> _extractCategories(CategoryState state) {
    if (state is ExpenseCategoriesLoaded) return state.categories;
    if (state is CategoryLoaded) return state.categories;
    return [];
  }
}

// =============================================================================
// Edit budget bottom sheet
// =============================================================================

class _EditBudgetSheet extends StatefulWidget {
  final BudgetEntity budget;

  const _EditBudgetSheet({required this.budget});

  @override
  State<_EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<_EditBudgetSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  late BudgetPeriod _selectedPeriod;
  CategoryEntity? _selectedCategory;
  late bool _isActive;
  bool _isSubmitting = false;
  bool _categoryError = false;

  @override
  void initState() {
    super.initState();
    final b = widget.budget;
    _nameController = TextEditingController(text: b.name);
    _amountController = TextEditingController(
      text: b.limitAmount.toStringAsFixed(2),
    );
    _selectedPeriod = b.period;
    _isActive = b.isActive;

    // Load expense categories and pre-select the budget's current one.
    context.read<CategoryBloc>().add(LoadExpenseCategoriesEvent());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _openCategoryPicker() async {
    final categoryBloc = context.read<CategoryBloc>();
    final picked = await showModalBottomSheet<CategoryEntity>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: categoryBloc,
        child: _CategoryPickerSheet(selected: _selectedCategory),
      ),
    );
    if (picked != null) {
      setState(() {
        _selectedCategory = picked;
        _categoryError = false;
      });
    }
  }

  void _submit() {
    final formValid = _formKey.currentState?.validate() ?? false;
    final categoryValid = _selectedCategory != null;
    setState(() => _categoryError = !categoryValid);
    if (!formValid || !categoryValid) return;

    setState(() => _isSubmitting = true);

    context.read<BudgetBloc>().add(
      UpdateBudgetEvent(
        budgetId: widget.budget.id,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        categoryId: _selectedCategory!.id,
        period: _selectedPeriod,
        isActive: _isActive,
        // Carry through existing dates — period change will be reflected
        // on next budget cycle.
        startDate: widget.budget.startDate,
        endDate: widget.budget.endDate,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return BlocListener<BudgetBloc, BudgetState>(
      listener: (context, state) {
        if (state is BudgetError) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppRadius.xxl),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.lg,
            AppSpacing.xxl,
            AppSpacing.xxl,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Drag handle ──────────────────────────────────────────────
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
                const SizedBox(height: AppSpacing.xl),

                // ── Title row with active toggle ─────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'budgets.edit_budget'.tr,
                        style: AppTextStyles.h3.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    // Active / inactive toggle
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isActive
                              ? 'budgets.status_active'.tr
                              : 'budgets.status_inactive'.tr,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: _isActive
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Switch.adaptive(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          activeThumbColor: AppColors.success,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // ── Budget name ──────────────────────────────────────────────
                AppTextField(
                  controller: _nameController,
                  label: 'budgets.field_name'.tr,
                  hint: 'budgets.field_name_hint'.tr,
                  textInputAction: TextInputAction.next,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'budgets.error_name_required'.tr;
                    }
                    if (v.trim().length > 100) {
                      return 'budgets.error_name_too_long'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Limit amount ─────────────────────────────────────────────
                AppTextField(
                  controller: _amountController,
                  label: 'budgets.field_amount'.tr,
                  hint: '0.00',
                  keyboardType: AppTextFieldKeyboardType.currency,
                  textInputAction: TextInputAction.done,
                  prefixText: 'RM ',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'budgets.error_amount_required'.tr;
                    }
                    final parsed = double.tryParse(v.trim());
                    if (parsed == null || parsed <= 0) {
                      return 'budgets.error_amount_invalid'.tr;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),

                // ── Category picker ──────────────────────────────────────────
                Text(
                  'budgets.field_category'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: _categoryError
                        ? AppColors.error
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),

                // Pre-populate once categories load if not yet picked manually.
                BlocListener<CategoryBloc, CategoryState>(
                  listener: (context, state) {
                    if (_selectedCategory != null) return;
                    final categories = _extractCategories(state);
                    final match = categories.where(
                      (c) => c.id == widget.budget.categoryId,
                    );
                    if (match.isNotEmpty) {
                      setState(() => _selectedCategory = match.first);
                    }
                  },
                  child: _CategoryPickerButton(
                    selected: _selectedCategory,
                    hasError: _categoryError,
                    onTap: _openCategoryPicker,
                  ),
                ),
                if (_categoryError) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'budgets.error_category_required'.tr,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),

                // ── Period picker ────────────────────────────────────────────
                Text(
                  'budgets.field_period'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                _PeriodSelector(
                  selected: _selectedPeriod,
                  onChanged: (p) => setState(() => _selectedPeriod = p),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // ── Save button ──────────────────────────────────────────────
                AppButton.primary(
                  label: _isSubmitting
                      ? 'general.saving'.tr
                      : 'general.save'.tr,
                  onPressed: _isSubmitting ? null : _submit,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<CategoryEntity> _extractCategories(CategoryState state) {
    if (state is ExpenseCategoriesLoaded) return state.categories;
    if (state is CategoryLoaded) return state.categories;
    return [];
  }
}
