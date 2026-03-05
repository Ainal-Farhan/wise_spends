import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_event.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_state.dart';
import 'package:wise_spends/presentation/widgets/components/empty_state_widget.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/presentation/widgets/charts/budget_charts.dart';
import 'package:wise_spends/presentation/screens/budget_plan/add_deposit_bottom_sheet.dart';
import 'package:wise_spends/presentation/screens/budget_plan/add_spending_bottom_sheet.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Budget Plan Detail Screen - Tabbed Interface
/// Tabs: Overview, Transactions, Charts
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
      child: _BudgetPlanDetailScreenContent(planUuid: planUuid),
    );
  }
}

class _BudgetPlanDetailScreenContent extends StatefulWidget {
  final String planUuid;

  const _BudgetPlanDetailScreenContent({required this.planUuid});

  @override
  State<_BudgetPlanDetailScreenContent> createState() =>
      _BudgetPlanDetailScreenContentState();
}

class _BudgetPlanDetailScreenContentState
    extends State<_BudgetPlanDetailScreenContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Plan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: ListTile(leading: Icon(Icons.edit), title: Text('Edit')),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: WiseSpendsColors.secondary,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(color: WiseSpendsColors.secondary),
                  ),
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
              text: loc.get('budget_plans.overview'),
            ),
            Tab(
              icon: const Icon(Icons.receipt_long),
              text: loc.get('budget_plans.transactions'),
            ),
            Tab(
              icon: const Icon(Icons.insights),
              text: loc.get('budget_plans.charts'),
            ),
          ],
        ),
      ),
      body: BlocConsumer<BudgetPlanDetailBloc, BudgetPlanDetailState>(
        listener: (context, state) {
          if (state is DepositAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.get('budget_plans.deposit_added')),
                backgroundColor: WiseSpendsColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is SpendingAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.get('budget_plans.spending_added')),
                backgroundColor: WiseSpendsColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is PlanDeleted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(loc.get('budget_plans.deleted')),
                backgroundColor: WiseSpendsColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is BudgetPlanDetailError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: WiseSpendsColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BudgetPlanDetailLoading) {
            return const DashboardShimmer();
          } else if (state is BudgetPlanDetailLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state),
                _buildTransactionsTab(state),
                _buildChartsTab(state),
              ],
            );
          } else if (state is BudgetPlanNotFound) {
            return const NoBudgetsEmptyState();
          } else if (state is BudgetPlanDetailError) {
            return ErrorStateWidget(message: state.message);
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildOverviewTab(BudgetPlanDetailLoaded state) {
    final plan = state.plan;
    final progress = plan.progressPercentage;
    final healthColor = _getHealthColor(plan.healthStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Card
          _buildProgressCard(plan, progress, healthColor),
          const SizedBox(height: 16),

          // Quick Actions
          _buildQuickActions(),
          const SizedBox(height: 24),

          // Milestones
          _buildMilestonesSection(state.milestones, state.plan.id, context),
          const SizedBox(height: 24),

          // Linked Accounts
          _buildLinkedAccountsSection(
            state.linkedAccounts,
            state.plan.id,
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(dynamic plan, double progress, Color healthColor) {
    final loc = LocalizationService();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [healthColor, healthColor.withValues(alpha: 0.7)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(plan.category.iconCode, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            plan.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            plan.category.displayName,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 0,
                    ).format(plan.currentAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loc.get('budget_plans.current_amount'),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 0,
                    ).format(plan.targetAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    loc.get('budget_plans.target_amount'),
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusChip(
                icon: plan.healthStatus == BudgetHealthStatus.onTrack
                    ? Icons.check_circle
                    : Icons.warning,
                label: plan.healthStatus.displayName,
                color: Colors.white,
              ),
              _buildStatusChip(
                icon: Icons.calendar_today,
                label: '${plan.daysRemaining} ${loc.get('general.days')}',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('budget_plans.quick_actions'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showAddDepositSheet,
                icon: const Icon(Icons.add),
                label: Text(loc.get('budget_plans.add_deposit')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WiseSpendsColors.success,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _showAddSpendingSheet,
                icon: const Icon(Icons.remove),
                label: Text(loc.get('budget_plans.add_spending')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: WiseSpendsColors.secondary,
                  minimumSize: const Size(0, 48),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMilestonesSection(
    List<dynamic> milestones,
    String planUuid,
    BuildContext context,
  ) {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              loc.get('budget_plans.milestones'),
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () => _showAddMilestoneDialog(context, planUuid),
              icon: const Icon(Icons.add, size: 18),
              label: Text(loc.get('budget_plans.add_milestone')),
            ),
          ],
        ),
        const SizedBox(height: 8),
        milestones.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: WiseSpendsColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 48,
                        color: WiseSpendsColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No milestones yet',
                        style: TextStyle(color: WiseSpendsColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: milestones.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _buildMilestoneCard(milestones[index], planUuid, context),
              ),
      ],
    );
  }

  Widget _buildMilestoneCard(
    dynamic milestone,
    String planUuid,
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: milestone.isCompleted
              ? WiseSpendsColors.success.withValues(alpha: 0.2)
              : WiseSpendsColors.primary.withValues(alpha: 0.2),
          child: Icon(
            milestone.isCompleted
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: milestone.isCompleted
                ? WiseSpendsColors.success
                : WiseSpendsColors.primary,
          ),
        ),
        title: Text(
          milestone.title,
          style: TextStyle(
            decoration: milestone.isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text('RM ${milestone.targetAmount.toStringAsFixed(2)}'),
        trailing: milestone.isCompleted
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () =>
                    _confirmCompleteMilestone(context, milestone.id!, planUuid),
              ),
      ),
    );
  }

  Widget _buildLinkedAccountsSection(
    List<dynamic> accounts,
    String planUuid,
    BuildContext context,
  ) {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('budget_plans.linked_accounts'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        accounts.isEmpty
            ? Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: WiseSpendsColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.account_balance,
                        size: 48,
                        color: WiseSpendsColors.textHint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No linked accounts',
                        style: TextStyle(color: WiseSpendsColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: accounts.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) =>
                    _buildLinkedAccountCard(accounts[index], planUuid, context),
              ),
      ],
    );
  }

  Widget _buildLinkedAccountCard(
    dynamic account,
    String planUuid,
    BuildContext context,
  ) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: const Icon(Icons.account_balance)),
        title: Text(account.accountName ?? 'Account'),
        subtitle: Text(
          'Allocated: RM ${(account.allocatedAmount ?? 0).toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link_off),
          onPressed: () =>
              _confirmUnlinkAccount(context, account.accountId, planUuid),
        ),
      ),
    );
  }

  Widget _buildTransactionsTab(BudgetPlanDetailLoaded state) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Deposits'),
              Tab(text: 'Spending'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildDepositsList(state.deposits),
                _buildSpendingList(state.transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepositsList(List<dynamic> deposits) {
    if (deposits.isEmpty) {
      return const Center(child: Text('No deposits yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: deposits.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildDepositCard(deposits[index]),
    );
  }

  Widget _buildDepositCard(dynamic deposit) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: WiseSpendsColors.success,
          child: Icon(Icons.arrow_downward, color: Colors.white),
        ),
        title: Text(deposit.source ?? 'Manual'),
        subtitle: Text(DateFormat('MMM d, y').format(deposit.depositDate)),
        trailing: Text(
          '+ RM ${deposit.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: WiseSpendsColors.success,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSpendingList(List<dynamic> transactions) {
    if (transactions.isEmpty) {
      return const Center(child: Text('No spending yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _buildSpendingCard(transactions[index]),
    );
  }

  Widget _buildSpendingCard(dynamic transaction) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: WiseSpendsColors.secondary,
          child: Icon(Icons.arrow_upward, color: Colors.white),
        ),
        title: Text(transaction.description ?? 'Spending'),
        subtitle: Text(
          DateFormat('MMM d, y').format(transaction.transactionDate),
        ),
        trailing: Text(
          '- RM ${transaction.amount.toStringAsFixed(2)}',
          style: const TextStyle(
            color: WiseSpendsColors.secondary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildChartsTab(BudgetPlanDetailLoaded state) {
    final totalDeposited = state.deposits.fold<double>(
      0.0,
      (sum, d) => sum + d.amount,
    );
    final totalSpent = state.transactions.fold<double>(
      0.0,
      (sum, t) => sum + t.amount,
    );

    // Prepare spending by category data
    var spendingByCategory = <SpendingByCategory>[];
    // Group transactions by vendor/description as category proxy
    if (totalSpent > 0) {
      final byVendor = <String, double>{};
      for (final transaction in state.transactions) {
        final key = transaction.vendor ?? transaction.description ?? 'Other';
        byVendor[key] = (byVendor[key] ?? 0) + transaction.amount;
      }

      spendingByCategory = byVendor.entries
          .map(
            (e) => SpendingByCategory(
              category: e.key,
              amount: e.value,
              percentage: (e.value / totalSpent) * 100,
            ),
          )
          .toList();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          _buildAnalyticsSummary(totalDeposited, totalSpent),
          const SizedBox(height: 24),

          // Monthly Contributions Chart
          _buildSectionTitle('Monthly Contributions'),
          const SizedBox(height: 8),
          BudgetMonthlyContributionsChart(
            data: state.analytics?.monthlyContributions ?? [],
            requiredMonthlySaving: state.plan.requiredMonthlySaving,
          ),
          const SizedBox(height: 24),

          // Progress Chart
          _buildSectionTitle('Savings Progress'),
          const SizedBox(height: 8),
          BudgetProgressChart(
            snapshots: state.analytics?.progressHistory ?? [],
            targetAmount: state.plan.targetAmount,
          ),
          const SizedBox(height: 24),

          // Spending Breakdown
          if (spendingByCategory.isNotEmpty) ...[
            _buildSectionTitle('Spending Breakdown'),
            const SizedBox(height: 8),
            BudgetSpendingDonutChart(
              data: spendingByCategory,
              totalSpent: totalSpent,
            ),
            const SizedBox(height: 16),
            BudgetChartLegend(data: spendingByCategory),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildAnalyticsSummary(double totalDeposited, double totalSpent) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Deposited',
            amount: totalDeposited,
            color: WiseSpendsColors.success,
            icon: Icons.add_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Spent',
            amount: totalSpent,
            color: WiseSpendsColors.secondary,
            icon: Icons.remove_circle,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12),
          ),
          Text(
            NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 0,
            ).format(amount),
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // Quick add based on current tab
        if (_tabController.index == 0) {
          _showAddDepositSheet();
        } else if (_tabController.index == 1) {
          _showAddSpendingSheet();
        }
      },
      child: const Icon(Icons.add),
    );
  }

  void _showAddDepositSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddDepositBottomSheet(planUuid: widget.planUuid),
    );
  }

  void _showAddSpendingSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddSpendingBottomSheet(planUuid: widget.planUuid),
    );
  }

  void _handleMenuAction(String value) {
    final state = context.read<BudgetPlanDetailBloc>().state;
    if (state is! BudgetPlanDetailLoaded) return;

    switch (value) {
      case 'edit':
        // Navigate to edit screen
        Navigator.pushNamed(
          context,
          AppRoutes.editBudgetPlan,
          arguments: widget.planUuid,
        );
        break;
      case 'delete':
        _confirmDelete(state.plan.id);
        break;
    }
  }

  void _confirmDelete(String uuid) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan?'),
        content: const Text(
          'Are you sure you want to delete this plan? All related data will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetPlanDetailBloc>().add(DeletePlanEvent(uuid));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.secondary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(BudgetHealthStatus status) {
    switch (status) {
      case BudgetHealthStatus.onTrack:
        return WiseSpendsColors.success;
      case BudgetHealthStatus.slightlyBehind:
        return WiseSpendsColors.warning;
      case BudgetHealthStatus.atRisk:
      case BudgetHealthStatus.overBudget:
        return WiseSpendsColors.secondary;
      case BudgetHealthStatus.completed:
        return WiseSpendsColors.primary;
    }
  }

  void _showAddMilestoneDialog(BuildContext context, String planUuid) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Milestone Title',
                  hintText: 'e.g., Venue Deposit',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Target Amount',
                  prefixText: 'RM ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  dueDate != null
                      ? 'Due: ${DateFormat('MMM d, y').format(dueDate!)}'
                      : 'Due Date (optional)',
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    setDialogState(() {
                      dueDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  context.read<BudgetPlanDetailBloc>().add(
                    AddMilestoneEvent(
                      title: titleController.text,
                      targetAmount: double.parse(amountController.text),
                      dueDate:
                          dueDate ??
                          DateTime.now().add(const Duration(days: 30)),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmCompleteMilestone(
    BuildContext context,
    String milestoneId,
    String planId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete Milestone?'),
        content: const Text('Mark this milestone as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetPlanDetailBloc>().add(
                CompleteMilestoneEvent(milestoneId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.success,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _confirmUnlinkAccount(
    BuildContext context,
    String accountId,
    String planId,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unlink Account?'),
        content: const Text(
          'This will remove the link between this account and the budget plan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<BudgetPlanDetailBloc>().add(
                UnlinkAccountEvent(accountId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.secondary,
            ),
            child: const Text('Unlink'),
          ),
        ],
      ),
    );
  }
}
