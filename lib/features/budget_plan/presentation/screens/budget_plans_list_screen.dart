import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/data/services/budget_plan_export_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_list_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_list_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_list_state.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// =============================================================================
// Root screen
// =============================================================================

class BudgetPlansListScreen extends StatelessWidget {
  const BudgetPlansListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return BlocProvider(
      create: (_) => BudgetPlanListBloc(repository)..add(LoadBudgetPlans()),
      child: const _BudgetPlansListContent(),
    );
  }
}

// =============================================================================
// Content — RouteAware so it silently refreshes after create/edit pop
// =============================================================================

class _BudgetPlansListContent extends StatefulWidget {
  const _BudgetPlansListContent();

  @override
  State<_BudgetPlansListContent> createState() =>
      _BudgetPlansListContentState();
}

class _BudgetPlansListContentState extends State<_BudgetPlansListContent>
    with RouteAware {
  bool _subscribed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_subscribed) {
      // Only subscribe once
      AppRouter.budgetPlanRouteObserver.subscribe(
        this,
        ModalRoute.of(context)!,
      );
      _subscribed = true;
    }
  }

  @override
  void dispose() {
    AppRouter.budgetPlanRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    context.read<BudgetPlanListBloc>().add(RefreshBudgetPlans());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('budget_plans.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: () => _confirmRecalculate(context),
            tooltip: 'budget_plans.recalculate'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'general.filter'.tr,
          ),
        ],
      ),
      body: BlocListener<BudgetPlanListBloc, BudgetPlanListState>(
        listener: (context, state) {
          if (state is BudgetPlanListDeleteError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BudgetPlanListRefreshError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BudgetPlanListRecalculateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BudgetPlanListRecalculated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('budget_plans.recalculated'.tr),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: RefreshIndicator(
          onRefresh: () async =>
              context.read<BudgetPlanListBloc>().add(RefreshBudgetPlans()),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    0,
                  ),
                  child: const _SummaryCard(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: const _FilterChips(),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                sliver: BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
                  builder: (context, state) {
                    if (state is BudgetPlanListLoading) {
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, _) => const BudgetCardShimmer(),
                          childCount: 5,
                        ),
                      );
                    }
                    if (state is BudgetPlanListLoaded) {
                      if (state.filteredPlans.isEmpty) {
                        return SliverToBoxAdapter(child: _buildEmpty(context));
                      }
                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _PlanCard(plan: state.filteredPlans[i]),
                          childCount: state.filteredPlans.length,
                        ),
                      );
                    }
                    if (state is BudgetPlanListEmpty) {
                      return SliverToBoxAdapter(child: _buildEmpty(context));
                    }
                    if (state is BudgetPlanListError) {
                      return SliverToBoxAdapter(
                        child: ErrorStateWidget(
                          message: state.message,
                          onAction: () => context
                              .read<BudgetPlanListBloc>()
                              .add(LoadBudgetPlans()),
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
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.createBudgetPlan),
        elevation: 4,
        tooltip: 'budget_plans.add'.tr,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'budget_plans.no_plans'.tr,
      subtitle: 'budget_plans.no_plans_subtitle'.tr,
      actionLabel: 'budget_plans.add'.tr,
      onAction: () => Navigator.pushNamed(context, AppRoutes.createBudgetPlan),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<BudgetPlanListBloc>(),
        child: const _FilterDialog(),
      ),
    );
  }

  void _confirmRecalculate(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.recalculate'.tr,
      message: 'budget_plans.recalculate_confirm'.tr,
      confirmText: 'budget_plans.recalculate'.tr,
      onConfirm: () {
        // Use WidgetsBinding to ensure the context is still valid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<BudgetPlanListBloc>().add(RecalculateBudgetPlans());
          }
        });
      },
    );
  }
}

// =============================================================================
// Summary card
// =============================================================================

class _SummaryCard extends StatelessWidget {
  const _SummaryCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        if (state is! BudgetPlanListLoaded) return const SizedBox.shrink();

        final BudgetPlanSummary summary = state.summary;
        final double progress = summary.overallProgressPercentage;
        final NumberFormat fmt = NumberFormat.currency(
          symbol: 'RM ',
          decimalDigits: 0,
        );

        return SectionHeader.card(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.tertiary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
          icon: Icons.pie_chart_outline,
          label: 'budget_plans.overall_summary'.tr,
          title: fmt.format(summary.totalSavedAmount),
          subtitle:
              '${'budget_plans.of_goal'.tr} ${fmt.format(summary.totalTargetAmount)}',
          collapsibleBody: _SummaryDetail(summary: summary, progress: progress),
          learnMoreLabel: 'general.details'.tr,
          learnLessLabel: 'general.less'.tr,
        );
      },
    );
  }
}

// WAS: final dynamic summary
class _SummaryDetail extends StatelessWidget {
  final BudgetPlanSummary summary;
  final double progress;

  const _SummaryDetail({required this.summary, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeaderBullet(
          '${summary.plansOnTrack} ${'budget_plans.plans_on_track'.tr}',
        ),
        SectionHeaderBullet(
          '${summary.plansAtRisk} ${'budget_plans.plans_at_risk'.tr}',
        ),
      ],
    );
  }
}

// =============================================================================
// Filter chips
// =============================================================================

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    return SectionHeaderCompact(
      title: 'general.filter'.tr,
      trailing: BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
        builder: (context, state) {
          final BudgetPlanStatus? current = state is BudgetPlanListLoaded
              ? state.filterStatus
              : null;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _chip(context, null, 'budget_plans.filter_all'.tr, current),
                const SizedBox(width: AppSpacing.xs),
                _chip(
                  context,
                  BudgetPlanStatus.active,
                  'budget_plans.filter_active'.tr,
                  current,
                ),
                const SizedBox(width: AppSpacing.xs),
                _chip(
                  context,
                  BudgetPlanStatus.completed,
                  'budget_plans.filter_completed'.tr,
                  current,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    BudgetPlanStatus? status,
    String label,
    BudgetPlanStatus? current,
  ) {
    final bool isSelected = current == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => context.read<BudgetPlanListBloc>().add(
        FilterBudgetPlans(status: selected ? status : null),
      ),
      selectedColor: Theme.of(
        context,
      ).colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }
}

// =============================================================================
// Plan card — WAS: final dynamic plan
// =============================================================================

class _PlanCard extends StatelessWidget {
  final BudgetPlanEntity plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final double progress = plan.progressPercentage.clamp(0.0, 1.0);
    final Color healthColor = _healthColor(context, plan.healthStatus);
    final NumberFormat fmt = NumberFormat.currency(
      symbol: 'RM',
      decimalDigits: 0,
    );

    // Calculate item payment status
    final hasItems = plan.totalItemCommitment > 0;
    final itemPaidTotal = plan.totalItemDepositPaid + plan.totalItemAmountPaid;
    final itemOutstanding = plan.totalItemOutstanding;
    final itemProgress = plan.totalItemCommitment > 0
        ? (itemPaidTotal / plan.totalItemCommitment).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: healthColor, width: 2),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.budgetPlanDetail,
          arguments: plan.id,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, name, category
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Text(
                        plan.category.iconCode,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.category.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Main progress bar (goal progress)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.xs),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: healthColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Goal progress amounts
              SectionHeaderCompact(
                title:
                    '${fmt.format(plan.currentAmount)} / ${fmt.format(plan.targetAmount)}',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      plan.healthStatus == BudgetHealthStatus.onTrack
                          ? Icons.check_circle
                          : Icons.warning,
                      size: AppIconSize.xs,
                      color: healthColor,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '${plan.healthStatus.displayName} · ${plan.daysRemaining}d',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Detailed amounts grid
              _AmountsGrid(
                currentAmount: plan.currentAmount,
                totalSpent: plan.totalSpent,
                totalDeposited: plan.totalDeposited,
                hasItems: hasItems,
                itemPaidTotal: itemPaidTotal,
                itemOutstanding: itemOutstanding,
                itemProgress: itemProgress,
                fmt: fmt,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // WAS: Color _healthColor(dynamic healthStatus)
  Color _healthColor(BuildContext context, BudgetHealthStatus healthStatus) {
    switch (healthStatus) {
      case BudgetHealthStatus.onTrack:
        return Theme.of(context).colorScheme.primary;
      case BudgetHealthStatus.slightlyBehind:
        return Theme.of(context).colorScheme.tertiary;
      case BudgetHealthStatus.atRisk:
      case BudgetHealthStatus.overBudget:
        return Theme.of(context).colorScheme.secondary;
      case BudgetHealthStatus.completed:
        return Theme.of(context).colorScheme.primary;
    }
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanListBloc>(),
        child: _PlanOptionsSheet(plan: plan),
      ),
    );
  }
}

// =============================================================================
// Amounts Grid - Shows detailed financial breakdown (collapsible)
// =============================================================================

class _AmountsGrid extends StatefulWidget {
  final double currentAmount;
  final double totalSpent;
  final double totalDeposited;
  final bool hasItems;
  final double itemPaidTotal;
  final double itemOutstanding;
  final double itemProgress;
  final NumberFormat fmt;

  const _AmountsGrid({
    required this.currentAmount,
    required this.totalSpent,
    required this.totalDeposited,
    required this.hasItems,
    required this.itemPaidTotal,
    required this.itemOutstanding,
    required this.itemProgress,
    required this.fmt,
  });

  @override
  State<_AmountsGrid> createState() => _AmountsGridState();
}

class _AmountsGridState extends State<_AmountsGrid> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Collapsible header
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'budget_plans.financial_breakdown'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isExpanded
                            ? 'general.collapse'.tr
                            : 'general.expand'.tr,
                        style: AppTextStyles.captionSmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: _buildCollapsedView(context),
            secondChild: _buildExpandedView(context),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactAmountRow(
            context,
            'budget_plans.available'.tr,
            widget.fmt.format(widget.currentAmount),
            Theme.of(context).colorScheme.primary,
          ),
          _buildCompactAmountRow(
            context,
            'budget_plans.spent'.tr,
            widget.fmt.format(widget.totalSpent),
            Theme.of(context).colorScheme.secondary,
          ),
          _buildCompactAmountRow(
            context,
            'budget_plans.deposited'.tr,
            widget.fmt.format(widget.totalDeposited),
            Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactAmountRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExpandedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md),
      child: Column(
        children: [
          // Available Amount
          _buildAmountRow(
            context,
            'budget_plans.available'.tr,
            widget.fmt.format(widget.currentAmount),
            Theme.of(context).colorScheme.primary,
            Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Spent Amount
          _buildAmountRow(
            context,
            'budget_plans.spent'.tr,
            widget.fmt.format(widget.totalSpent),
            Theme.of(context).colorScheme.secondary,
            Icons.north_outlined,
          ),
          const SizedBox(height: AppSpacing.sm),
          // Deposited Amount
          _buildAmountRow(
            context,
            'budget_plans.deposited'.tr,
            widget.fmt.format(widget.totalDeposited),
            Theme.of(context).colorScheme.primary,
            Icons.south_outlined,
          ),
          // Item payments (if has items)
          if (widget.hasItems) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),
            // Item payment summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'budget_plans.item_payments'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    widget.fmt.format(widget.itemPaidTotal),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Item payment progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: widget.itemProgress,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // Outstanding amount
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'budget_plans.outstanding'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  widget.fmt.format(widget.itemOutstanding),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: widget.itemOutstanding > 0
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountRow(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppSpacing.sm),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Plan options sheet — WAS: final dynamic plan
// =============================================================================

class _PlanOptionsSheet extends StatelessWidget {
  final BudgetPlanEntity plan;

  const _PlanOptionsSheet({required this.plan});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text('budget_plans.edit_plan'.tr),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(
                context,
                AppRoutes.editBudgetPlan,
                arguments: plan.id,
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.flag_outlined,
              color: plan.status == BudgetPlanStatus.completed
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.tertiary,
            ),
            title: Text('budget_plans.end_plan'.tr),
            subtitle: Text(
              'budget_plans.end_plan_subtitle'.tr,
              style: AppTextStyles.captionSmall,
            ),
            onTap: () {
              Navigator.pop(context);
              _showEndPlanDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text('budget_plans.recalculate_plan'.tr),
            onTap: () {
              Navigator.pop(context);
              _confirmRecalculatePlan(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text('budget_plans.export_plan'.tr),
            onTap: () async {
              Navigator.pop(context);
              await _export(context);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              'general.delete'.tr,
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context);
            },
          ),
        ],
      ),
    );
  }

  // WAS: Future<void> _export(BuildContext context, dynamic plan)
  Future<void> _export(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final BudgetPlanEntity? planToExport =
          await SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getBudgetPlanRepository()
              .getPlanByUuid(plan.id);

      if (planToExport != null) {
        final BudgetPlanExportService svc = BudgetPlanExportService();
        final String path = await svc.exportToCsv(planToExport);
        await svc.shareExport(path);

        if (context.mounted) {
          messenger.showSnackBar(
            SnackBar(
              content: Text('budget_plans.plan_exported'.tr),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'budget_plans.export_failed'.trWith({'error': e.toString()}),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  // WAS: void _confirmDelete(BuildContext context, dynamic plan)
  void _confirmDelete(BuildContext context) {
    final bloc = context.read<BudgetPlanListBloc>();

    showDeleteDialog(
      context: context,
      title: 'budget_plans.delete_plan'.tr,
      message: 'budget_plans.delete_plan_msg'.tr,
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      onDelete: () {
        bloc.add(DeleteBudgetPlan(plan.id));
      },
    );
  }

  void _confirmRecalculatePlan(BuildContext context) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.recalculate_plan'.tr,
      message: 'budget_plans.recalculate_plan_confirm'.tr,
      confirmText: 'budget_plans.recalculate'.tr,
      onConfirm: () {
        // Use WidgetsBinding to ensure the context is still valid
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.read<BudgetPlanListBloc>().add(RecalculateBudgetPlans());
          }
        });
      },
    );
  }

  void _showEndPlanDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<BudgetPlanListBloc>(),
        child: _EndPlanDialog(plan: plan),
      ),
    );
  }
}

// =============================================================================
// End Plan Dialog - allows changing plan status
// =============================================================================

class _EndPlanDialog extends StatefulWidget {
  final BudgetPlanEntity plan;

  const _EndPlanDialog({required this.plan});

  @override
  State<_EndPlanDialog> createState() => _EndPlanDialogState();
}

class _EndPlanDialogState extends State<_EndPlanDialog> {
  BudgetPlanStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.plan.status;
  }

  @override
  Widget build(BuildContext context) {
    return CustomDialog(
      config: CustomDialogConfig(
        title: 'budget_plans.end_plan'.tr,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'budget_plans.end_plan_description'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'budget_plans.select_status'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              children: [
                _statusRadio(
                  context,
                  BudgetPlanStatus.completed,
                  'budget_plans.status_completed'.tr,
                  Icons.check_circle,
                  Theme.of(context).colorScheme.primary,
                ),
                _statusRadio(
                  context,
                  BudgetPlanStatus.paused,
                  'budget_plans.status_paused'.tr,
                  Icons.pause_circle,
                  Theme.of(context).colorScheme.tertiary,
                ),
                _statusRadio(
                  context,
                  BudgetPlanStatus.cancelled,
                  'budget_plans.status_cancelled'.tr,
                  Icons.cancel,
                  Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
        buttons: [
          CustomDialogButton(
            text: 'general.cancel'.tr,
            onPressed: () => Navigator.pop(context),
          ),
          CustomDialogButton(
            text: 'general.confirm'.tr,
            isDefault: true,
            onPressed:
                _selectedStatus != null && _selectedStatus != widget.plan.status
                ? () {
                    context.read<BudgetPlanListBloc>().add(
                      UpdateBudgetPlanStatus(
                        uuid: widget.plan.id,
                        status: _selectedStatus!,
                      ),
                    );
                    Navigator.pop(context);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _statusRadio(
    BuildContext context,
    BudgetPlanStatus status,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedStatus == status;
    return InkWell(
      onTap: () => setState(() => _selectedStatus = status),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm,
          horizontal: AppSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isSelected
                      ? color
                      : Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            RadioGroup<BudgetPlanStatus>(
              groupValue: _selectedStatus,
              onChanged: (value) => setState(() => _selectedStatus = value),
              child: Radio<BudgetPlanStatus>(value: status),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Filter dialog
// =============================================================================

class _FilterDialog extends StatelessWidget {
  const _FilterDialog();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        final BudgetPlanStatus? current = state is BudgetPlanListLoaded
            ? state.filterStatus
            : null;

        return CustomDialog(
          config: CustomDialogConfig(
            title: 'general.filter'.tr,
            content: RadioGroup<BudgetPlanStatus?>(
              groupValue: current,
              onChanged: (BudgetPlanStatus? v) {
                context.read<BudgetPlanListBloc>().add(
                  FilterBudgetPlans(status: v),
                );
                Navigator.pop(context);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text('budget_plans.filter_all'.tr),
                    value: null,
                  ),
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text('budget_plans.filter_active'.tr),
                    value: BudgetPlanStatus.active,
                  ),
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text('budget_plans.filter_completed'.tr),
                    value: BudgetPlanStatus.completed,
                  ),
                ],
              ),
            ),
            buttons: [
              CustomDialogButton(
                text: 'general.clear'.tr,
                onPressed: () {
                  context.read<BudgetPlanListBloc>().add(FilterBudgetPlans());
                  Navigator.pop(context);
                },
              ),
              CustomDialogButton(
                text: 'general.close'.tr,
                isDefault: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
