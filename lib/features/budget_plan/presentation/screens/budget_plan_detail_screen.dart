import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_state.dart';
import 'package:wise_spends/features/budget_plan/presentation/screens/add_milestone_bottom_sheet.dart';
import 'package:wise_spends/features/budget_plan/presentation/screens/add_spending_bottom_sheet.dart';
import 'package:wise_spends/features/budget_plan/presentation/screens/budget_plan_items_list_screen.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_overview_tab.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_charts_tab.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_transactions_tab.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_edit_allocation_sheet.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/shared/components/speed_dial_fab.dart';
import 'package:wise_spends/shared/components/empty_state_widget.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';

/// Budget Plan Detail Screen — Tabbed Interface (Overview · Items · Transactions · Charts)
class BudgetPlanDetailScreen extends StatelessWidget {
  final String planUuid;

  const BudgetPlanDetailScreen({super.key, required this.planUuid});

  @override
  Widget build(BuildContext context) {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return BlocProvider(
      create: (context) =>
          BudgetPlanDetailBloc(repository)..add(LoadPlanDetail(planUuid)),
      child: _BudgetPlanDetailContent(planUuid: planUuid),
    );
  }
}

class _BudgetPlanDetailContent extends StatefulWidget {
  final String planUuid;

  const _BudgetPlanDetailContent({required this.planUuid});

  @override
  State<_BudgetPlanDetailContent> createState() =>
      _BudgetPlanDetailContentState();
}

class _BudgetPlanDetailContentState extends State<_BudgetPlanDetailContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _currentTabIndex = _tabController.index;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<BudgetPlanDetailBloc, BudgetPlanDetailState>(
        listener: _handleStateListener,
        builder: (context, state) {
          if (state is BudgetPlanDetailLoading) {
            return const DashboardShimmer();
          }
          if (state is BudgetPlanDetailLoaded) {
            return _buildTabView(state);
          }
          if (state is BudgetPlanNotFound) {
            return const NoBudgetsEmptyState();
          }
          if (state is BudgetPlanDetailError) {
            return ErrorStateWidget(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _DetailFAB(
        currentTabIndex: _currentTabIndex,
        onAddDeposit: _showAddDepositSheet,
        onAddSpending: _showAddSpendingSheet,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text('budget_plans.title'.tr),
      actions: [
        PopupMenuButton<String>(
          onSelected: _handleMenuAction,
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: const Icon(Icons.edit),
                title: Text('general.edit'.tr),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(
                  Icons.delete,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  'general.delete'.tr,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: const Icon(Icons.dashboard),
            text: 'budget_plans.overview'.tr,
          ),
          Tab(
            icon: const Icon(Icons.format_list_bulleted),
            text: 'budget_plans.items'.tr,
          ),
          Tab(
            icon: const Icon(Icons.receipt_long),
            text: 'budget_plans.transactions'.tr,
          ),
          Tab(icon: const Icon(Icons.insights), text: 'budget_plans.charts'.tr),
        ],
      ),
    );
  }

  Widget _buildTabView(BudgetPlanDetailLoaded state) {
    return TabBarView(
      controller: _tabController,
      children: [
        BudgetPlanOverviewTab(
          plan: state.plan,
          milestones: state.milestones,
          linkedAccounts: state.linkedAccounts,
          onAddDeposit: () => _showAddDepositSheet(),
          onAddSpending: () => _showAddSpendingSheet(),
          onAddMilestone: (planUuid) => _showAddMilestoneDialog(planUuid),
          onCompleteMilestone: _confirmCompleteMilestone,
          onDeleteMilestone: _confirmDeleteMilestone,
          onUnlinkAccount: _confirmUnlinkAccount,
          onEditAllocation: _showEditAllocationSheet,
        ),
        BudgetPlanItemsListScreen(planId: widget.planUuid),
        BudgetPlanTransactionsTab(state: state),
        BudgetPlanChartsTab(plan: state.plan, planUuid: widget.planUuid),
      ],
    );
  }

  void _handleStateListener(BuildContext context, BudgetPlanDetailState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state is DepositAdded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.deposit_added'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is SpendingAdded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.spending_added'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is MilestoneDeleted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.milestone_deleted'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PlanDeleted) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.deleted'.tr),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is BudgetPlanDetailError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handleMenuAction(String value) {
    final state = context.read<BudgetPlanDetailBloc>().state;
    if (state is! BudgetPlanDetailLoaded) return;

    switch (value) {
      case 'edit':
        Navigator.pushNamed(
          context,
          AppRoutes.editBudgetPlan,
          arguments: widget.planUuid,
        );
      case 'delete':
        _confirmDelete(state.plan.id);
    }
  }

  void _showAddDepositSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: AddDepositBottomSheet(planUuid: widget.planUuid),
      ),
    );
  }

  void _showAddSpendingSheet() {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: AddSpendingBottomSheet(planUuid: widget.planUuid),
      ),
    );
  }

  void _confirmDelete(String uuid) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.delete_plan'.tr,
      message: 'budget_plans.delete_plan_msg'.tr,
      confirmText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.delete_outline,
      iconColor: Theme.of(context).colorScheme.error,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(DeletePlanEvent(uuid));
      },
    );
  }

  void _showAddMilestoneDialog(String planUuid) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: AddMilestoneBottomSheet(planId: planUuid),
      ),
    );
  }

  void _confirmCompleteMilestone(String milestoneId, String planId) {
    if (!mounted) return;
    showConfirmDialog(
      context: context,
      title: 'budget_plans.complete_milestone'.tr,
      message: 'budget_plans.complete_milestone_msg'.tr,
      confirmText: 'general.confirm'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.check_circle,
      iconColor: Theme.of(context).colorScheme.primary,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(
          CompleteMilestoneEvent(milestoneId),
        );
      },
    );
  }

  void _confirmDeleteMilestone(String milestoneId, String planId) {
    context.read<BudgetPlanDetailBloc>().add(DeleteMilestoneEvent(milestoneId));
  }

  void _confirmUnlinkAccount(String accountId, String planId) {
    if (!mounted) return;
    showConfirmDialog(
      context: context,
      title: 'budget_plans.unlink_account'.tr,
      message: 'budget_plans.unlink_account_msg'.tr,
      confirmText: 'general.unlink'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.link_off,
      iconColor: Theme.of(context).colorScheme.tertiary,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(UnlinkAccountEvent(accountId));
      },
    );
  }

  void _showEditAllocationSheet(
    String accountId,
    String planId,
    double currentAmount,
  ) {
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: EditAllocationSheet(
          planId: planId,
          accountId: accountId,
          currentAmount: currentAmount,
        ),
      ),
    );
  }
}

// =============================================================================
// Detail FAB - kept inline for simplicity
// =============================================================================

class _DetailFAB extends StatelessWidget {
  final int currentTabIndex;
  final VoidCallback? onAddDeposit;
  final VoidCallback? onAddSpending;

  const _DetailFAB({
    required this.currentTabIndex,
    this.onAddDeposit,
    this.onAddSpending,
  });

  @override
  Widget build(BuildContext context) {
    if (currentTabIndex != 2) return const SizedBox.shrink();

    return SpeedDialFab(
      actions: [
        SpeedDialAction(
          icon: Icons.add_circle_outline,
          label: 'budget_plans.add_deposit'.tr,
          onPressed: onAddDeposit ?? () {},
        ),
        SpeedDialAction(
          icon: Icons.money_off_csred,
          label: 'budget_plans.add_spending'.tr,
          onPressed: onAddSpending ?? () {},
        ),
      ],
    );
  }
}
