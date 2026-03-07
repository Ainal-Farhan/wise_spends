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
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/presentation/widgets/charts/budget_charts.dart';
import 'package:wise_spends/presentation/screens/budget_plan/add_bottom_sheet.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_analytics.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Budget Plan Detail Screen — Tabbed Interface (Overview · Transactions · Charts)
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
    return Scaffold(
      appBar: AppBar(
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
                  leading: const Icon(
                    Icons.delete,
                    color: WiseSpendsColors.secondary,
                  ),
                  title: Text(
                    'general.delete'.tr,
                    style: const TextStyle(color: WiseSpendsColors.secondary),
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
              icon: const Icon(Icons.receipt_long),
              text: 'budget_plans.transactions'.tr,
            ),
            Tab(
              icon: const Icon(Icons.insights),
              text: 'budget_plans.charts'.tr,
            ),
          ],
        ),
      ),
      body: BlocConsumer<BudgetPlanDetailBloc, BudgetPlanDetailState>(
        listener: _handleStateListener,
        builder: (context, state) {
          if (state is BudgetPlanDetailLoading) {
            return const DashboardShimmer();
          }
          if (state is BudgetPlanDetailLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(
                  state: state,
                  onAddDeposit: _showAddDepositSheet,
                  onAddSpending: _showAddSpendingSheet,
                  onAddMilestone: (planUuid) =>
                      _showAddMilestoneDialog(context, planUuid),
                  onCompleteMilestone: (milestoneId, planId) =>
                      _confirmCompleteMilestone(context, milestoneId, planId),
                  onUnlinkAccount: (accountId, planId) =>
                      _confirmUnlinkAccount(context, accountId, planId),
                ),
                _TransactionsTab(state: state),
                _ChartsTab(state: state),
              ],
            );
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
        tabController: _tabController,
        onDeposit: _showAddDepositSheet,
        onSpending: _showAddSpendingSheet,
      ),
    );
  }

  void _handleStateListener(BuildContext context, BudgetPlanDetailState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state is DepositAdded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.deposit_added'.tr),
          backgroundColor: WiseSpendsColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is SpendingAdded) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.spending_added'.tr),
          backgroundColor: WiseSpendsColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is PlanDeleted) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.deleted'.tr),
          backgroundColor: WiseSpendsColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else if (state is BudgetPlanDetailError) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: WiseSpendsColors.error,
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
              context.read<BudgetPlanDetailBloc>().add(DeletePlanEvent(uuid));
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

  void _showAddMilestoneDialog(BuildContext context, String planUuid) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime? dueDate;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('budget_plans.add_milestone_title'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'budget_plans.milestone_title'.tr,
                hint: 'budget_plans.milestone_title_hint'.tr,
                controller: titleCtrl,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'budget_plans.target_amount'.tr,
                hint: '0.00',
                prefixText: 'RM ',
                controller: amountCtrl,
                keyboardType: AppTextFieldKeyboardType.decimal,
              ),
              const SizedBox(height: AppSpacing.lg),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: Text(
                  dueDate != null
                      ? '${'general.due'.tr}: ${DateFormat('MMM d, y').format(dueDate!)}'
                      : 'budget_plans.due_date_optional'.tr,
                ),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                  );
                  if (picked != null) {
                    setDialogState(() => dueDate = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            AppButton.text(
              label: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            AppButton.primary(
              label: 'general.add'.tr,
              onPressed: () {
                if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
                  context.read<BudgetPlanDetailBloc>().add(
                    AddMilestoneEvent(
                      title: titleCtrl.text,
                      targetAmount: double.parse(amountCtrl.text),
                      dueDate:
                          dueDate ??
                          DateTime.now().add(const Duration(days: 30)),
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
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
      builder: (ctx) => AlertDialog(
        title: Text('budget_plans.complete_milestone'.tr),
        content: Text('budget_plans.complete_milestone_msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetPlanDetailBloc>().add(
                CompleteMilestoneEvent(milestoneId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.success,
            ),
            child: Text('budget_plans.complete'.tr),
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
      builder: (ctx) => AlertDialog(
        title: Text('budget_plans.unlink_account'.tr),
        content: Text('budget_plans.unlink_account_msg'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('general.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<BudgetPlanDetailBloc>().add(
                UnlinkAccountEvent(accountId),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: WiseSpendsColors.secondary,
            ),
            child: Text('budget_plans.unlink'.tr),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Overview tab
// =============================================================================

class _OverviewTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;
  final VoidCallback onAddDeposit;
  final VoidCallback onAddSpending;
  final ValueChanged<String> onAddMilestone;
  final void Function(String milestoneId, String planId) onCompleteMilestone;
  final void Function(String accountId, String planId) onUnlinkAccount;

  const _OverviewTab({
    required this.state,
    required this.onAddDeposit,
    required this.onAddSpending,
    required this.onAddMilestone,
    required this.onCompleteMilestone,
    required this.onUnlinkAccount,
  });

  @override
  Widget build(BuildContext context) {
    final plan = state.plan;
    final healthColor = _healthColor(plan.healthStatus);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress card (using SectionHeader.card)
          SectionHeader.card(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [healthColor, healthColor.withValues(alpha: 0.7)],
            ),
            icon: Icons.account_balance_wallet_outlined,
            label: plan.category.displayName,
            title: plan.name,
            subtitle: _progressSubtitle(plan),
            collapsibleBody: _ProgressBody(plan: plan, color: healthColor),
            learnMoreLabel: 'general.details'.tr,
            learnLessLabel: 'general.less'.tr,
          ),

          // Quick actions
          SectionHeader(title: 'budget_plans.quick_actions'.tr),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: AppButton.primary(
                  label: 'budget_plans.add_deposit'.tr,
                  icon: Icons.add,
                  onPressed: onAddDeposit,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: AppButton.secondary(
                  label: 'budget_plans.add_spending'.tr,
                  icon: Icons.remove,
                  onPressed: onAddSpending,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Milestones
          SectionHeader(
            title: 'budget_plans.milestones'.tr,
            trailing: TextButton.icon(
              onPressed: () => onAddMilestone(state.plan.id),
              icon: const Icon(Icons.add, size: AppIconSize.sm),
              label: Text('budget_plans.add_milestone'.tr),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (state.milestones.isEmpty)
            _EmptySection(
              icon: Icons.flag_outlined,
              messageKey: 'budget_plans.no_milestones',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.milestones.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _MilestoneCard(
                milestone: state.milestones[i],
                planId: state.plan.id,
                onComplete: onCompleteMilestone,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),

          // Linked accounts
          SectionHeader(title: 'budget_plans.linked_accounts'.tr),
          const SizedBox(height: AppSpacing.sm),
          if (state.linkedAccounts.isEmpty)
            _EmptySection(
              icon: Icons.account_balance,
              messageKey: 'budget_plans.no_linked_accounts',
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.linkedAccounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _LinkedAccountCard(
                account: state.linkedAccounts[i],
                planId: state.plan.id,
                onUnlink: onUnlinkAccount,
              ),
            ),
        ],
      ),
    );
  }

  String _progressSubtitle(dynamic plan) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);
    return '${fmt.format(plan.currentAmount)} / ${fmt.format(plan.targetAmount)} · ${plan.daysRemaining} ${'general.days'.tr} ${'general.remaining'.tr}';
  }

  Color _healthColor(BudgetHealthStatus status) {
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
}

/// Collapsible body shown inside the SectionHeader.card progress card.
class _ProgressBody extends StatelessWidget {
  final dynamic plan;
  final Color color;

  const _ProgressBody({required this.plan, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = (plan.progressPercentage as double).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Progress bar
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.full),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 12,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _StatusChip(
              icon: plan.healthStatus == BudgetHealthStatus.onTrack
                  ? Icons.check_circle
                  : Icons.warning,
              label: plan.healthStatus.displayName,
            ),
            const SizedBox(width: AppSpacing.md),
            _StatusChip(
              icon: Icons.calendar_today,
              label: '${(progress * 100).toInt()}% ${'general.complete'.tr}',
            ),
          ],
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatusChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppIconSize.xs, color: Colors.white),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String messageKey;

  const _EmptySection({required this.icon, required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: WiseSpendsColors.textHint),
            const SizedBox(height: AppSpacing.sm),
            Text(
              messageKey.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MilestoneCard extends StatelessWidget {
  final dynamic milestone;
  final String planId;
  final void Function(String milestoneId, String planId) onComplete;

  const _MilestoneCard({
    required this.milestone,
    required this.planId,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
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
        subtitle: Text(
          'RM ${(milestone.targetAmount as double).toStringAsFixed(2)}',
        ),
        trailing: milestone.isCompleted
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => onComplete(milestone.id!, planId),
              ),
      ),
    );
  }
}

class _LinkedAccountCard extends StatelessWidget {
  final dynamic account;
  final String planId;
  final void Function(String accountId, String planId) onUnlink;

  const _LinkedAccountCard({
    required this.account,
    required this.planId,
    required this.onUnlink,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.account_balance)),
        title: Text(account.accountName ?? 'Account'),
        subtitle: Text(
          '${'budget_plans.allocated'.tr}: RM ${((account.allocatedAmount ?? 0) as double).toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.link_off),
          onPressed: () => onUnlink(account.accountId as String, planId),
        ),
      ),
    );
  }
}

// =============================================================================
// Transactions tab
// =============================================================================

class _TransactionsTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const _TransactionsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'budget_plans.deposits'.tr),
              Tab(text: 'budget_plans.spending'.tr),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _DepositsList(deposits: state.deposits),
                _SpendingList(transactions: state.transactions),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DepositsList extends StatelessWidget {
  final List<dynamic> deposits;

  const _DepositsList({required this.deposits});

  @override
  Widget build(BuildContext context) {
    if (deposits.isEmpty) {
      return Center(child: Text('budget_plans.no_deposits'.tr));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: deposits.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _DepositCard(deposit: deposits[i]),
    );
  }
}

class _DepositCard extends StatelessWidget {
  final dynamic deposit;

  const _DepositCard({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: WiseSpendsColors.success,
          child: Icon(Icons.arrow_downward, color: Colors.white),
        ),
        title: Text(deposit.source ?? 'Manual'),
        subtitle: Text(DateFormat('MMM d, y').format(deposit.depositDate)),
        trailing: Text(
          '+ RM ${(deposit.amount as double).toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: WiseSpendsColors.success,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SpendingList extends StatelessWidget {
  final List<dynamic> transactions;

  const _SpendingList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return Center(child: Text('budget_plans.no_spending'.tr));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => _SpendingCard(transaction: transactions[i]),
    );
  }
}

class _SpendingCard extends StatelessWidget {
  final dynamic transaction;

  const _SpendingCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
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
          '- RM ${(transaction.amount as double).toStringAsFixed(2)}',
          style: AppTextStyles.bodyMedium.copyWith(
            color: WiseSpendsColors.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Charts tab
// =============================================================================

class _ChartsTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const _ChartsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final totalDeposited = state.deposits.fold<double>(
      0.0,
      (s, d) => s + (d.amount),
    );
    final totalSpent = state.transactions.fold<double>(
      0.0,
      (s, t) => s + (t.amount),
    );

    final spendingByCategory = _buildCategoryData(totalSpent);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary via SectionHeader.card
          SectionHeader.card(
            gradient: const LinearGradient(
              colors: [WiseSpendsColors.primary, WiseSpendsColors.primaryDark],
            ),
            icon: Icons.insights,
            label: 'budget_plans.charts'.tr,
            title: 'budget_plans.analytics_title'.tr,
            subtitle: _analyticsSummary(totalDeposited, totalSpent),
          ),

          SectionHeader(title: 'budget_plans.monthly_contributions'.tr),
          const SizedBox(height: AppSpacing.sm),
          BudgetMonthlyContributionsChart(
            data: state.analytics?.monthlyContributions ?? [],
            requiredMonthlySaving: state.plan.requiredMonthlySaving,
          ),
          const SizedBox(height: AppSpacing.xxl),

          SectionHeader(title: 'budget_plans.savings_progress'.tr),
          const SizedBox(height: AppSpacing.sm),
          BudgetProgressChart(
            snapshots: state.analytics?.progressHistory ?? [],
            targetAmount: state.plan.targetAmount,
          ),
          const SizedBox(height: AppSpacing.xxl),

          if (spendingByCategory.isNotEmpty) ...[
            SectionHeader(title: 'budget_plans.spending_breakdown'.tr),
            const SizedBox(height: AppSpacing.sm),
            BudgetSpendingDonutChart(
              data: spendingByCategory,
              totalSpent: totalSpent,
            ),
            const SizedBox(height: AppSpacing.md),
            BudgetChartLegend(data: spendingByCategory),
          ],
        ],
      ),
    );
  }

  List<SpendingByCategory> _buildCategoryData(double totalSpent) {
    if (totalSpent <= 0) return [];
    final byVendor = <String, double>{};
    for (final t in state.transactions) {
      final key = t.vendor ?? t.description ?? 'Other';
      byVendor[key] = (byVendor[key] ?? 0) + (t.amount);
    }
    return byVendor.entries
        .map(
          (e) => SpendingByCategory(
            category: e.key,
            amount: e.value,
            percentage: (e.value / totalSpent) * 100,
          ),
        )
        .toList();
  }

  String _analyticsSummary(double deposited, double spent) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);
    return '${'budget_plans.deposited'.tr}: ${fmt.format(deposited)}  ·  ${'budget_plans.spent'.tr}: ${fmt.format(spent)}';
  }
}

// =============================================================================
// FAB
// =============================================================================

class _DetailFAB extends StatelessWidget {
  final TabController tabController;
  final VoidCallback onDeposit;
  final VoidCallback onSpending;

  const _DetailFAB({
    required this.tabController,
    required this.onDeposit,
    required this.onSpending,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        if (tabController.index == 1) {
          onSpending();
        } else {
          onDeposit();
        }
      },
      child: const Icon(Icons.add),
    );
  }
}
