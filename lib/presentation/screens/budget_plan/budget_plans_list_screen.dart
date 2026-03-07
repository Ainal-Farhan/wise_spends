import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/services/budget_plan_export_service.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_event.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_state.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Budget Plans List Screen
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

class _BudgetPlansListContent extends StatelessWidget {
  const _BudgetPlansListContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('budget_plans.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: 'general.filter'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<BudgetPlanListBloc>().add(RefreshBudgetPlans()),
        child: CustomScrollView(
          slivers: [
            // ── Summary card ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: _SummaryCard(),
              ),
            ),

            // ── Filter chips ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                child: _FilterChips(),
              ),
            ),

            // ── Plans list ─────────────────────────────────────────────────
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
                        onAction: () => context.read<BudgetPlanListBloc>().add(
                          LoadBudgetPlans(),
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
        child: _FilterDialog(),
      ),
    );
  }
}

// =============================================================================
// Summary card
// =============================================================================

class _SummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        if (state is! BudgetPlanListLoaded) return const SizedBox.shrink();

        final summary = state.summary;
        final progress = summary.overallProgressPercentage;
        final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);

        return SectionHeader.card(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [WiseSpendsColors.tertiary, WiseSpendsColors.tertiaryDark],
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

class _SummaryDetail extends StatelessWidget {
  final dynamic summary;
  final double progress;

  const _SummaryDetail({required this.summary, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
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
        Row(
          children: [
            SectionHeaderBullet(
              '${summary.plansOnTrack} ${'budget_plans.plans_on_track'.tr}',
            ),
          ],
        ),
        Row(
          children: [
            SectionHeaderBullet(
              '${summary.plansAtRisk} ${'budget_plans.plans_at_risk'.tr}',
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Filter chips
// =============================================================================

class _FilterChips extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SectionHeaderCompact(
      title: 'general.filter'.tr,
      trailing: BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
        builder: (context, state) {
          final current = state is BudgetPlanListLoaded
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
    final isSelected = current == status;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (s) => context.read<BudgetPlanListBloc>().add(
        FilterBudgetPlans(status: s ? status : null),
      ),
      selectedColor: WiseSpendsColors.primary.withValues(alpha: 0.2),
      checkmarkColor: WiseSpendsColors.primary,
    );
  }
}

// =============================================================================
// Plan card
// =============================================================================

class _PlanCard extends StatelessWidget {
  final dynamic plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final progress = (plan.progressPercentage as double).clamp(0.0, 1.0);
    final healthColor = _healthColor(plan.healthStatus);

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
          arguments: plan.uuid,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
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
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.category.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: WiseSpendsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showOptions(context, plan),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Progress bar
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

              // Amount + health row using SectionHeaderCompact
              SectionHeaderCompact(
                title:
                    '${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(plan.currentAmount)} / ${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(plan.targetAmount)}',
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
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _healthColor(dynamic healthStatus) {
    switch (healthStatus) {
      case BudgetHealthStatus.onTrack:
        return WiseSpendsColors.success;
      case BudgetHealthStatus.slightlyBehind:
        return WiseSpendsColors.warning;
      case BudgetHealthStatus.atRisk:
      case BudgetHealthStatus.overBudget:
        return WiseSpendsColors.secondary;
      case BudgetHealthStatus.completed:
        return WiseSpendsColors.primary;
      default:
        return WiseSpendsColors.textHint;
    }
  }

  void _showOptions(BuildContext context, dynamic plan) {
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
// Plan options sheet
// =============================================================================

class _PlanOptionsSheet extends StatelessWidget {
  final dynamic plan;

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
                arguments: plan.uuid,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.file_download_outlined),
            title: Text('budget_plans.export_plan'.tr),
            onTap: () async {
              Navigator.pop(context);
              await _export(context, plan);
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.delete_outline,
              color: WiseSpendsColors.secondary,
            ),
            title: Text(
              'general.delete'.tr,
              style: const TextStyle(color: WiseSpendsColors.secondary),
            ),
            onTap: () {
              Navigator.pop(context);
              _confirmDelete(context, plan);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, dynamic plan) async {
    try {
      final planToExport =
          await SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getBudgetPlanRepository()
              .getPlanByUuid(plan.uuid);

      if (planToExport != null) {
        final svc = BudgetPlanExportService();
        final path = await svc.exportToCsv(planToExport);
        await svc.shareExport(path);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('budget_plans.plan_exported'.tr),
              backgroundColor: WiseSpendsColors.success,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'budget_plans.export_failed'.trWith({'error': e.toString()}),
            ),
            backgroundColor: WiseSpendsColors.error,
          ),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context, dynamic plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('budget_plans.delete_plan'.tr),
        content: Text('budget_plans.delete_plan_msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetPlanListBloc>().add(
                DeleteBudgetPlan(plan.uuid),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.secondary,
            ),
            child: Text('general.delete'.tr),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Filter dialog
// =============================================================================

class _FilterDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        final current = state is BudgetPlanListLoaded
            ? state.filterStatus
            : null;

        void select(BudgetPlanStatus? v) {
          context.read<BudgetPlanListBloc>().add(FilterBudgetPlans(status: v));
          Navigator.pop(context);
        }

        return AlertDialog(
          title: Text('general.filter'.tr),
          content: RadioGroup<BudgetPlanStatus?>(
            groupValue: current,
            onChanged: select,
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
          actions: [
            TextButton(
              onPressed: () {
                context.read<BudgetPlanListBloc>().add(FilterBudgetPlans());
                Navigator.pop(context);
              },
              child: Text('general.clear'.tr),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('general.close'.tr),
            ),
          ],
        );
      },
    );
  }
}
