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
import 'package:wise_spends/presentation/widgets/components/empty_state_widget.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Budget Plans List Screen
/// Features:
/// - Overall summary card
/// - Filter chips (All/Active/Completed)
/// - Budget plan cards with progress
/// - Color-coded by health status
/// - FAB to create new plan
class BudgetPlansListScreen extends StatelessWidget {
  const BudgetPlansListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return BlocProvider(
      create: (context) =>
          BudgetPlanListBloc(repository)..add(LoadBudgetPlans()),
      child: const _BudgetPlansListScreenContent(),
    );
  }
}

class _BudgetPlansListScreenContent extends StatefulWidget {
  const _BudgetPlansListScreenContent();

  @override
  State<_BudgetPlansListScreenContent> createState() =>
      _BudgetPlansListScreenContentState();
}

class _BudgetPlansListScreenContentState
    extends State<_BudgetPlansListScreenContent> {
  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('budget_plans.title')),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
            tooltip: loc.get('general.filter'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<BudgetPlanListBloc>().add(RefreshBudgetPlans());
        },
        child: CustomScrollView(
          slivers: [
            // Overall Summary Card
            SliverToBoxAdapter(child: _buildSummaryCard(context)),

            // Filter Chips
            SliverToBoxAdapter(child: _buildFilterChips(context)),

            // Plans List
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
                builder: (context, state) {
                  if (state is BudgetPlanListLoading) {
                    return _buildShimmerList();
                  } else if (state is BudgetPlanListLoaded) {
                    if (state.filteredPlans.isEmpty) {
                      return SliverToBoxAdapter(
                        child: EmptyStateWidget(
                          icon: Icons.account_balance_wallet_outlined,
                          title: loc.get('budget_plans.no_plans'),
                          subtitle: loc.get('budget_plans.no_plans_subtitle'),
                          actionLabel: loc.get('budget_plans.add'),
                          onAction: () => _navigateToCreatePlan(context),
                        ),
                      );
                    }
                    return _buildPlansList(context, state.filteredPlans);
                  } else if (state is BudgetPlanListEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyStateWidget(
                        icon: Icons.account_balance_wallet_outlined,
                        title: loc.get('budget_plans.no_plans'),
                        subtitle: loc.get('budget_plans.no_plans_subtitle'),
                        actionLabel: loc.get('budget_plans.add'),
                        onAction: () => _navigateToCreatePlan(context),
                      ),
                    );
                  } else if (state is BudgetPlanListError) {
                    return SliverToBoxAdapter(
                      child: ErrorStateWidget(
                        message: state.message,
                        onAction: () {
                          context.read<BudgetPlanListBloc>().add(
                            LoadBudgetPlans(),
                          );
                        },
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
        onPressed: () => _navigateToCreatePlan(context),
        elevation: 4,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    final loc = LocalizationService();

    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        if (state is BudgetPlanListLoaded) {
          final summary = state.summary;
          final progress = summary.overallProgressPercentage;

          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  WiseSpendsColors.tertiary,
                  WiseSpendsColors.tertiaryDark,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: WiseSpendsColors.tertiary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.pie_chart_outline,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  loc.get('budget_plans.overall_summary'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  NumberFormat.currency(
                    symbol: 'RM ',
                    decimalDigits: 0,
                  ).format(summary.totalSavedAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'of ${NumberFormat.currency(symbol: 'RM ', decimalDigits: 0).format(summary.totalTargetAmount)} goal',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSummaryChip(
                      context,
                      label:
                          '${summary.plansOnTrack} ${loc.get('budget_plans.plans_on_track')}',
                      color: WiseSpendsColors.success,
                    ),
                    const SizedBox(width: 16),
                    _buildSummaryChip(
                      context,
                      label:
                          '${summary.plansAtRisk} ${loc.get('budget_plans.plans_at_risk')}',
                      color: WiseSpendsColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildSummaryChip(
    BuildContext context, {
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final loc = LocalizationService();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              label: loc.get('budget_plans.filter_all'),
              status: null,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: loc.get('budget_plans.filter_active'),
              status: BudgetPlanStatus.active,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              label: loc.get('budget_plans.filter_completed'),
              status: BudgetPlanStatus.completed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    BudgetPlanStatus? status,
  }) {
    return BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
      builder: (context, state) {
        BudgetPlanStatus? currentStatus;
        if (state is BudgetPlanListLoaded) {
          currentStatus = state.filterStatus;
        }
        
        final isSelected = currentStatus == status;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          onSelected: (selected) {
            context.read<BudgetPlanListBloc>().add(
              FilterBudgetPlans(status: selected ? status : null),
            );
          },
          selectedColor: WiseSpendsColors.primary.withValues(alpha: 0.2),
          checkmarkColor: WiseSpendsColors.primary,
        );
      },
    );
  }

  Widget _buildPlansList(BuildContext context, List<dynamic> plans) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildPlanCard(context, plans[index]),
        childCount: plans.length,
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, dynamic plan) {
    final progress = plan.progressPercentage;
    final healthColor = _getHealthColor(plan.healthStatus);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: healthColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _navigateToPlanDetail(context, plan.uuid),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: healthColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      plan.category.iconCode,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          plan.category.displayName,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: WiseSpendsColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  // More button
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _showPlanOptions(context, plan),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: healthColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(healthColor),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              // Amount and days
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(plan.currentAmount)} / ${NumberFormat.currency(symbol: 'RM', decimalDigits: 0).format(plan.targetAmount)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: healthColor,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        plan.healthStatus == BudgetHealthStatus.onTrack
                            ? Icons.check_circle
                            : Icons.warning,
                        size: 16,
                        color: healthColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${plan.healthStatus.displayName} • ${plan.daysRemaining}d left',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: WiseSpendsColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getHealthColor(dynamic healthStatus) {
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

  Widget _buildShimmerList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => const BudgetCardShimmer(),
        childCount: 5,
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final loc = LocalizationService();

    showDialog(
      context: context,
      builder: (dialogContext) => BlocBuilder<BudgetPlanListBloc, BudgetPlanListState>(
        builder: (context, state) {
          BudgetPlanStatus? currentStatus;
          if (state is BudgetPlanListLoaded) {
            currentStatus = state.filterStatus;
          }
          
          return AlertDialog(
            title: Text(loc.get('general.filter')),
            content: RadioGroup<BudgetPlanStatus?>(
              groupValue: currentStatus,
              onChanged: (value) {
                Navigator.pop(dialogContext);
                context.read<BudgetPlanListBloc>().add(
                  FilterBudgetPlans(status: value),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text(loc.get('budget_plans.filter_all')),
                    value: null,
                  ),
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text(loc.get('budget_plans.filter_active')),
                    value: BudgetPlanStatus.active,
                  ),
                  RadioListTile<BudgetPlanStatus?>(
                    title: Text(loc.get('budget_plans.filter_completed')),
                    value: BudgetPlanStatus.completed,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<BudgetPlanListBloc>().add(FilterBudgetPlans());
                  Navigator.pop(dialogContext);
                },
                child: Text(loc.get('general.clear')),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(loc.get('general.close')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _navigateToCreatePlan(BuildContext context) {
    Navigator.pushNamed(context, '/budget-plan/create');
  }

  void _navigateToPlanDetail(BuildContext context, String uuid) {
    Navigator.pushNamed(context, '/budget-plan/detail', arguments: uuid);
  }

  void _showPlanOptions(BuildContext context, dynamic plan) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text('budget_plans.edit_plan'.tr),
              onTap: () {
                Navigator.pop(context);
                // Navigate to edit plan screen
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
                try {
                  // Export plan to CSV
                  final exportService = BudgetPlanExportService();
                  final planToExport = await SingletonUtil.getSingleton<IRepositoryLocator>()!
                      .getBudgetPlanRepository()
                      .getPlanByUuid(plan.uuid);

                  if (planToExport != null) {
                    final filePath = await exportService.exportToCsv(planToExport);
                    await exportService.shareExport(filePath);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('budget_plans.plan_exported'.tr),
                        backgroundColor: WiseSpendsColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('budget_plans.export_failed'.trWith({'error': e.toString()})),
                      backgroundColor: WiseSpendsColors.error,
                    ),
                  );
                }
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
                _confirmDeletePlan(context, plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePlan(BuildContext context, dynamic plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('budget_plans.delete_plan'.tr),
        content: Text('budget_plans.delete_plan_msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('general.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
