import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_milestone_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_state.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/screens/add_spending_bottom_sheet.dart';
import 'package:wise_spends/features/budget_plan/presentation/screens/budget_plan_items_list_screen.dart';
import 'package:wise_spends/presentation/widgets/loaders/shimmer_loader.dart';
import 'package:wise_spends/features/budget/presentation/widgets/budget_charts.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_analytics.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/speed_dial_fab.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
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
    _tabController = TabController(length: 4, vsync: this);
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
              icon: const Icon(Icons.format_list_bulleted),
              text: 'budget_plans.items'.tr,
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
                  onDeleteMilestone: (milestoneId, planId) =>
                      _confirmDeleteMilestone(context, milestoneId, planId),
                  onUnlinkAccount: (accountId, planId) =>
                      _confirmUnlinkAccount(context, accountId, planId),
                ),
                BudgetPlanItemsListScreen(planId: widget.planUuid),
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
    } else if (state is MilestoneDeleted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('budget_plans.milestone_deleted'.tr),
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
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<BudgetPlanDetailBloc>()),
          BlocProvider(
            create: (_) => TransactionBloc(
              SingletonUtil.getSingleton<IRepositoryLocator>()!
                  .getTransactionRepository(),
              SingletonUtil.getSingleton<IRepositoryLocator>()!
                  .getSavingRepository(),
            ),
          ),
        ],
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
      iconColor: AppColors.error,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(DeletePlanEvent(uuid));
      },
    );
  }

  void _showAddMilestoneDialog(BuildContext context, String planUuid) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    DateTime? dueDate;

    // Constants for milestone date picker
    const maxYearsFuture = 5;

    showCustomContentDialog(
      context: context,
      title: 'budget_plans.add_milestone_title'.tr,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) => Column(
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
                  lastDate: DateTime.now().add(
                    const Duration(days: 365 * maxYearsFuture),
                  ),
                );
                if (picked != null) {
                  setDialogState(() => dueDate = picked);
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        DialogAction(
          text: 'general.cancel'.tr,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          text: 'general.add'.tr,
          isPrimary: true,
          onPressed: () {
            if (titleCtrl.text.isNotEmpty && amountCtrl.text.isNotEmpty) {
              context.read<BudgetPlanDetailBloc>().add(
                AddMilestoneEvent(
                  title: titleCtrl.text,
                  targetAmount: double.parse(amountCtrl.text),
                  dueDate:
                      dueDate ?? DateTime.now().add(const Duration(days: 30)),
                ),
              );
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }

  void _confirmCompleteMilestone(
    BuildContext context,
    String milestoneId,
    String planId,
  ) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.complete_milestone'.tr,
      message: 'budget_plans.complete_milestone_msg'.tr,
      confirmText: 'budget_plans.complete'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.check_circle_outline,
      iconColor: AppColors.success,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(
          CompleteMilestoneEvent(milestoneId),
        );
      },
    );
  }

  void _confirmDeleteMilestone(
    BuildContext context,
    String milestoneId,
    String planId,
  ) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.delete_milestone'.tr,
      message: 'budget_plans.delete_milestone_msg'.tr,
      confirmText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.delete_outline,
      iconColor: AppColors.error,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(
          DeleteMilestoneEvent(milestoneId),
        );
      },
    );
  }

  void _confirmUnlinkAccount(
    BuildContext context,
    String accountId,
    String planId,
  ) {
    showConfirmDialog(
      context: context,
      title: 'budget_plans.unlink_account'.tr,
      message: 'budget_plans.unlink_account_msg'.tr,
      confirmText: 'budget_plans.unlink_account'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.link_off,
      iconColor: AppColors.warning,
      onConfirm: () {
        context.read<BudgetPlanDetailBloc>().add(UnlinkAccountEvent(accountId));
      },
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
  final void Function(String milestoneId, String planId) onDeleteMilestone;
  final void Function(String accountId, String planId) onUnlinkAccount;

  const _OverviewTab({
    required this.state,
    required this.onAddDeposit,
    required this.onAddSpending,
    required this.onAddMilestone,
    required this.onCompleteMilestone,
    required this.onDeleteMilestone,
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
          // Progress card
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
          const SizedBox(height: AppSpacing.xxl),

          // Quick actions — enhanced
          _QuickActionsSection(
            onAddDeposit: onAddDeposit,
            onAddSpending: onAddSpending,
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
                onDelete: onDeleteMilestone,
              ),
            ),
          const SizedBox(height: AppSpacing.xxl),

          // Linked accounts
          SectionHeader(
            title: 'budget_plans.linked_accounts'.tr,
            trailing: TextButton.icon(
              onPressed: () => _showLinkAccountSheet(context),
              icon: const Icon(Icons.add_link, size: AppIconSize.sm),
              label: Text('budget_plans.link_account'.tr),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          // Explanation text
          Text(
            'budget_plans.linked_accounts_desc'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (state.linkedAccounts.isEmpty)
            _LinkedAccountsEmpty(onLink: () => _showLinkAccountSheet(context))
          else
            Column(
              children: [
                // Total allocated banner
                _LinkedAccountsTotalBanner(
                  accounts: state.linkedAccounts,
                  planTarget: state.plan.targetAmount,
                ),
                const SizedBox(height: AppSpacing.md),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.linkedAccounts.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) => _LinkedAccountCard(
                    account: state.linkedAccounts[i],
                    planId: state.plan.id,
                    onUnlink: onUnlinkAccount,
                  ),
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showLinkAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: _LinkAccountSheet(planId: state.plan.id),
      ),
    );
  }

  String _progressSubtitle(BudgetPlanEntity plan) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 0);
    final days = plan.daysRemaining.clamp(0, 9999);
    return '${fmt.format(plan.currentAmount)} / ${fmt.format(plan.targetAmount)} · $days ${'general.days'.tr} ${'general.remaining'.tr}';
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

// =============================================================================
// Quick Actions — enhanced mobile-friendly layout
// =============================================================================

class _QuickActionsSection extends StatelessWidget {
  final VoidCallback onAddDeposit;
  final VoidCallback onAddSpending;

  const _QuickActionsSection({
    required this.onAddDeposit,
    required this.onAddSpending,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'budget_plans.quick_actions'.tr),
        const SizedBox(height: AppSpacing.md),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.add_circle_outline,
                  label: 'budget_plans.add_deposit'.tr,
                  sublabel: 'budget_plans.add_deposit_desc'.tr,
                  color: WiseSpendsColors.success,
                  onTap: onAddDeposit,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ActionCard(
                  icon: Icons.remove_circle_outline,
                  label: 'budget_plans.add_spending'.tr,
                  sublabel: 'budget_plans.add_spending_desc'.tr,
                  color: WiseSpendsColors.secondary,
                  onTap: onAddSpending,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: color.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: color, size: AppIconSize.md),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Linked Accounts — total banner + empty state + link sheet
// =============================================================================

class _LinkedAccountsTotalBanner extends StatelessWidget {
  final List<LinkedAccountSummaryEntity> accounts;
  final double planTarget;

  const _LinkedAccountsTotalBanner({
    required this.accounts,
    required this.planTarget,
  });

  @override
  Widget build(BuildContext context) {
    final totalAllocated = accounts.fold<double>(
      0.0,
      (s, a) => s + a.allocatedAmount,
    );
    final progress = planTarget > 0
        ? (totalAllocated / planTarget).clamp(0.0, 1.0)
        : 0.0;
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: WiseSpendsColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_outlined,
                size: 16,
                color: WiseSpendsColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'budget_plans.total_allocated'.tr,
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${accounts.length} ${'budget_plans.accounts'.tr}',
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            fmt.format(totalAllocated),
            style: AppTextStyles.amountMedium.copyWith(
              color: WiseSpendsColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.full),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: WiseSpendsColors.primary.withValues(alpha: 0.15),
              valueColor: const AlwaysStoppedAnimation(
                WiseSpendsColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% ${'budget_plans.of_target'.tr}',
            style: AppTextStyles.caption.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkedAccountsEmpty extends StatelessWidget {
  final VoidCallback onLink;

  const _LinkedAccountsEmpty({required this.onLink});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: WiseSpendsColors.divider,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.account_balance_outlined,
            size: 40,
            color: WiseSpendsColors.textHint,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'budget_plans.no_linked_accounts'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'budget_plans.no_linked_accounts_desc'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.primary(
            label: 'budget_plans.link_account'.tr,
            icon: Icons.add_link,
            onPressed: onLink,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Link Account bottom sheet
// ---------------------------------------------------------------------------

class _LinkAccountSheet extends StatefulWidget {
  final String planId;

  const _LinkAccountSheet({required this.planId});

  @override
  State<_LinkAccountSheet> createState() => _LinkAccountSheetState();
}

class _LinkAccountSheetState extends State<_LinkAccountSheet> {
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: WiseSpendsColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: WiseSpendsColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.add_link,
                      color: WiseSpendsColors.primary,
                      size: AppIconSize.md,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('budget_plans.link_account'.tr, style: AppTextStyles.h2),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'budget_plans.link_account_desc'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Account picker
              SectionHeaderCompact(
                title: 'budget_plans.select_savings_account'.tr,
              ),
              const SizedBox(height: AppSpacing.sm),
              FutureBuilder<List<SavingVO>>(
                future: repository.getAvailableSavingsAccounts(widget.planId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const ShimmerCard(height: 56);
                  }
                  final accounts = snapshot.data ?? [];
                  if (accounts.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: WiseSpendsColors.surface,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: WiseSpendsColors.divider),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: WiseSpendsColors.textHint,
                            size: 20,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(
                            'budget_plans.no_savings_to_link'.tr,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: WiseSpendsColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    children: accounts.map((account) {
                      final isSelected = _selectedAccountId == account.savingId;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: InkWell(
                          onTap: () => setState(() {
                            _selectedAccountId = account.savingId;
                          }),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          child: Container(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? WiseSpendsColors.primary.withValues(
                                      alpha: 0.08,
                                    )
                                  : WiseSpendsColors.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(
                                color: isSelected
                                    ? WiseSpendsColors.primary
                                    : WiseSpendsColors.divider,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: WiseSpendsColors.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.sm,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.savings_outlined,
                                    color: WiseSpendsColors.primary,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        account.savingName ?? '',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'RM ${(account.currentAmount ?? .0).toStringAsFixed(2)}',
                                        style: AppTextStyles.caption.copyWith(
                                          color: WiseSpendsColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: WiseSpendsColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Allocation amount
              AppTextField(
                label: 'budget_plans.allocated_amount'.tr,
                hint: '0.00',
                prefixText: 'RM ',
                controller: _amountCtrl,
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'budget_plans.required'.tr;
                  }
                  final val = double.tryParse(v);
                  if (val == null || val <= 0) {
                    return 'error.validation.invalid_amount'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton.primary(
                label: 'budget_plans.link_account'.tr,
                icon: Icons.add_link,
                isFullWidth: true,
                onPressed: _selectedAccountId == null ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    context.read<BudgetPlanDetailBloc>().add(
      LinkAccountEvent(
        accountId: _selectedAccountId!,
        allocatedAmount: double.parse(_amountCtrl.text),
      ),
    );
    Navigator.pop(context);
  }
}

// =============================================================================
// Unchanged widgets — kept as-is
// =============================================================================

class _ProgressBody extends StatelessWidget {
  final BudgetPlanEntity plan;
  final Color color;

  const _ProgressBody({required this.plan, required this.color});

  @override
  Widget build(BuildContext context) {
    final progress = plan.progressPercentage.clamp(0.0, 1.0);
    final healthStatus = plan.healthStatus;
    final String healthLabel;
    switch (healthStatus) {
      case BudgetHealthStatus.onTrack:
        healthLabel = 'budget_plans.health_on_track'.tr;
      case BudgetHealthStatus.slightlyBehind:
        healthLabel = 'budget_plans.health_slightly_behind'.tr;
      case BudgetHealthStatus.atRisk:
        healthLabel = 'budget_plans.health_at_risk'.tr;
      case BudgetHealthStatus.overBudget:
        healthLabel = 'budget_plans.health_over_budget'.tr;
      case BudgetHealthStatus.completed:
        healthLabel = 'budget_plans.health_completed'.tr;
    }
    final percentageDisplay = (progress * 100).clamp(0, 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              icon: healthStatus == BudgetHealthStatus.onTrack
                  ? Icons.check_circle
                  : Icons.warning,
              label: healthLabel,
            ),
            const SizedBox(width: AppSpacing.md),
            _StatusChip(
              icon: Icons.calendar_today,
              label: '$percentageDisplay% ${'general.complete'.tr}',
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
  final BudgetPlanMilestoneEntity milestone;
  final String planId;
  final void Function(String milestoneId, String planId) onComplete;
  final void Function(String milestoneId, String planId) onDelete;

  const _MilestoneCard({
    required this.milestone,
    required this.planId,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('milestone_${milestone.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => showDeleteDialog(
        context: context,
        title: 'budget_plans.delete_milestone'.tr,
        message: 'budget_plans.delete_milestone_msg'.trWith({'title': milestone.title}),
        deleteText: 'general.delete'.tr,
        cancelText: 'general.cancel'.tr,
      ),
      onDismissed: (_) => onDelete(milestone.id, planId),
      background: Container(
        decoration: BoxDecoration(
          color: WiseSpendsColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.xl),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      child: _MilestoneCardContent(
        milestone: milestone,
        planId: planId,
        onComplete: onComplete,
      ),
    );
  }
}

class _MilestoneCardContent extends StatelessWidget {
  final BudgetPlanMilestoneEntity milestone;
  final String planId;
  final void Function(String milestoneId, String planId) onComplete;

  const _MilestoneCardContent({
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
        subtitle: Text('RM ${milestone.targetAmount.toStringAsFixed(2)}'),
        trailing: milestone.isCompleted
            ? null
            : IconButton(
                icon: const Icon(Icons.check_circle_outline),
                onPressed: () => onComplete(milestone.id, planId),
              ),
      ),
    );
  }
}

class _LinkedAccountCard extends StatelessWidget {
  final LinkedAccountSummaryEntity account;
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
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: WiseSpendsColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: const Icon(
            Icons.savings_outlined,
            color: WiseSpendsColors.primary,
            size: AppIconSize.md,
          ),
        ),
        title: Text(
          account.accountName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${'budget_plans.allocated'.tr}: RM ${account.allocatedAmount.toStringAsFixed(2)}',
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(
            Icons.link_off,
            color: WiseSpendsColors.textHint,
            size: 20,
          ),
          tooltip: 'budget_plans.unlink'.tr,
          onPressed: () => onUnlink(account.accountId, planId),
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
    final totalDeposited = state.deposits.fold<double>(
      0.0,
      (s, d) => s + d.amount,
    );
    final totalSpent = state.transactions.fold<double>(
      0.0,
      (s, t) => s + t.amount,
    );
    final net = totalDeposited - totalSpent;

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Summary strip
          _TransactionSummaryStrip(
            totalDeposited: totalDeposited,
            totalSpent: totalSpent,
            net: net,
          ),

          // Sub-tabs
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.arrow_downward, size: 16),
                text: 'budget_plans.deposits'.tr,
              ),
              Tab(
                icon: const Icon(Icons.arrow_upward, size: 16),
                text: 'budget_plans.spending'.tr,
              ),
            ],
          ),

          Expanded(
            child: TabBarView(
              children: [
                _DepositsList(
                  deposits: state.deposits,
                  totalDeposited: totalDeposited,
                ),
                _SpendingList(
                  transactions: state.transactions,
                  totalSpent: totalSpent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Summary Strip
// ---------------------------------------------------------------------------

class _TransactionSummaryStrip extends StatelessWidget {
  final double totalDeposited;
  final double totalSpent;
  final double net;

  const _TransactionSummaryStrip({
    required this.totalDeposited,
    required this.totalSpent,
    required this.net,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        border: Border(
          bottom: BorderSide(color: WiseSpendsColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          _SummaryCell(
            label: 'budget_plans.deposits'.tr,
            amount: totalDeposited,
            color: WiseSpendsColors.success,
            icon: Icons.arrow_downward,
          ),
          _SummaryDivider(),
          _SummaryCell(
            label: 'budget_plans.spending'.tr,
            amount: totalSpent,
            color: WiseSpendsColors.secondary,
            icon: Icons.arrow_upward,
          ),
          _SummaryDivider(),
          _SummaryCell(
            label: 'budget_plans.net'.tr,
            amount: net,
            color: net >= 0
                ? WiseSpendsColors.success
                : WiseSpendsColors.secondary,
            icon: net >= 0 ? Icons.trending_up : Icons.trending_down,
          ),
        ],
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCell({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          AmountText(
            amount: amount,
            type: AmountType.neutral,
            showPrefix: false,
            style: AppTextStyles.bodySemiBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: WiseSpendsColors.divider,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
    );
  }
}

// ---------------------------------------------------------------------------
// Deposits list
// ---------------------------------------------------------------------------

class _DepositsList extends StatelessWidget {
  final List<BudgetPlanDepositEntity> deposits;
  final double totalDeposited;

  const _DepositsList({required this.deposits, required this.totalDeposited});

  @override
  Widget build(BuildContext context) {
    if (deposits.isEmpty) {
      return _EmptyTransactions(
        icon: Icons.savings_outlined,
        messageKey: 'budget_plans.no_deposits',
      );
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
  final BudgetPlanDepositEntity deposit;

  const _DepositCard({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('deposit_${deposit.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(
        context,
        message: 'budget_plans.delete_deposit_msg'.tr,
      ),
      onDismissed: (_) =>
          context.read<BudgetPlanDetailBloc>().add(DeleteDeposit(deposit.id)),
      background: _DeleteSlideBackground(),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _showDepositDetail(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WiseSpendsColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _sourceIcon(deposit.source),
                    color: WiseSpendsColors.success,
                    size: AppIconSize.md,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        deposit.sourceDisplayName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat('EEE, MMM d, y').format(deposit.depositDate),
                        style: AppTextStyles.caption.copyWith(
                          color: WiseSpendsColors.textSecondary,
                        ),
                      ),
                      if (deposit.note != null && deposit.note!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          deposit.note!,
                          style: AppTextStyles.caption.copyWith(
                            color: WiseSpendsColors.textHint,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Amount + delete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '+ RM ${deposit.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: WiseSpendsColors.success,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final confirmed = await _confirmDelete(
                          context,
                          message: 'budget_plans.delete_deposit_msg'.tr,
                        );
                        if (confirmed == true && context.mounted) {
                          context.read<BudgetPlanDetailBloc>().add(
                            DeleteDeposit(deposit.id),
                          );
                        }
                      },
                      child: Icon(
                        Icons.delete_outline,
                        size: 18,
                        color: WiseSpendsColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _sourceIcon(String? source) {
    switch (source) {
      case 'linked_account':
        return Icons.account_balance;
      case 'salary':
        return Icons.work_outline;
      case 'bonus':
        return Icons.card_giftcard_outlined;
      default:
        return Icons.add_circle_outline;
    }
  }

  void _showDepositDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => _DepositDetailSheet(deposit: deposit),
    );
  }
}

class _DepositDetailSheet extends StatelessWidget {
  final BudgetPlanDepositEntity deposit;

  const _DepositDetailSheet({required this.deposit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WiseSpendsColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: WiseSpendsColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.arrow_downward,
                  color: WiseSpendsColors.success,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(deposit.sourceDisplayName, style: AppTextStyles.h2),
                    Text(
                      'budget_plans.deposit'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '+ RM ${deposit.amount.toStringAsFixed(2)}',
                style: AppTextStyles.amountMedium.copyWith(
                  color: WiseSpendsColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'general.date'.tr,
            value: DateFormat('EEEE, MMMM d, y').format(deposit.depositDate),
          ),
          if (deposit.note != null && deposit.note!.isNotEmpty)
            _DetailRow(
              icon: Icons.note_outlined,
              label: 'general.note'.tr,
              value: deposit.note!,
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Spending list
// ---------------------------------------------------------------------------

class _SpendingList extends StatelessWidget {
  final List<BudgetPlanTransactionEntity> transactions;
  final double totalSpent;

  const _SpendingList({required this.transactions, required this.totalSpent});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return _EmptyTransactions(
        icon: Icons.receipt_long_outlined,
        messageKey: 'budget_plans.no_spending',
      );
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
  final BudgetPlanTransactionEntity transaction;

  const _SpendingCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final hasReceipt =
        transaction.receiptImagePath != null &&
        transaction.receiptImagePath!.isNotEmpty;

    return Dismissible(
      key: Key('spending_${transaction.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(
        context,
        message: 'budget_plans.delete_spending_msg'.tr,
      ),
      onDismissed: (_) => context.read<BudgetPlanDetailBloc>().add(
        DeleteSpending(transaction.id),
      ),
      background: _DeleteSlideBackground(),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: () => _showSpendingDetail(context),
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: WiseSpendsColors.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: WiseSpendsColors.secondary,
                    size: AppIconSize.md,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description ?? 'budget_plans.spending'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            DateFormat(
                              'EEE, MMM d, y',
                            ).format(transaction.transactionDate),
                            style: AppTextStyles.caption.copyWith(
                              color: WiseSpendsColors.textSecondary,
                            ),
                          ),
                          if (transaction.vendor != null) ...[
                            Text(
                              '  ·  ',
                              style: AppTextStyles.caption.copyWith(
                                color: WiseSpendsColors.textHint,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                transaction.vendor!,
                                style: AppTextStyles.caption.copyWith(
                                  color: WiseSpendsColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Amount + receipt + delete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '- RM ${transaction.amount.toStringAsFixed(2)}',
                      style: AppTextStyles.bodySemiBold.copyWith(
                        color: WiseSpendsColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasReceipt)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Icon(
                              Icons.receipt_outlined,
                              size: 16,
                              color: WiseSpendsColors.primary,
                            ),
                          ),
                        GestureDetector(
                          onTap: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              message: 'budget_plans.delete_spending_msg'.tr,
                            );
                            if (confirmed == true && context.mounted) {
                              context.read<BudgetPlanDetailBloc>().add(
                                DeleteSpending(transaction.id),
                              );
                            }
                          },
                          child: Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: WiseSpendsColors.textHint,
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
      ),
    );
  }

  void _showSpendingDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: _SpendingDetailSheet(transaction: transaction),
      ),
    );
  }
}

class _SpendingDetailSheet extends StatelessWidget {
  final BudgetPlanTransactionEntity transaction;

  const _SpendingDetailSheet({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final hasReceipt =
        transaction.receiptImagePath != null &&
        transaction.receiptImagePath!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: WiseSpendsColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: WiseSpendsColors.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.arrow_upward,
                  color: WiseSpendsColors.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description ?? 'budget_plans.spending'.tr,
                      style: AppTextStyles.h2,
                    ),
                  ],
                ),
              ),
              Text(
                '- RM ${transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.amountMedium.copyWith(
                  color: WiseSpendsColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Detail rows
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'general.date'.tr,
            value: DateFormat(
              'EEEE, MMMM d, y',
            ).format(transaction.transactionDate),
          ),
          if (transaction.vendor != null && transaction.vendor!.isNotEmpty)
            _DetailRow(
              icon: Icons.store_outlined,
              label: 'budget_plans.vendor'.tr,
              value: transaction.vendor!,
            ),

          // Receipt
          if (hasReceipt) ...[
            const SizedBox(height: AppSpacing.lg),
            SectionHeaderCompact(title: 'budget_plans.receipt'.tr),
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.asset(
                transaction.receiptImagePath!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: WiseSpendsColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: WiseSpendsColors.divider),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.broken_image_outlined,
                          color: WiseSpendsColors.textHint,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'budget_plans.receipt_unavailable'.tr,
                          style: AppTextStyles.caption.copyWith(
                            color: WiseSpendsColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xxl),

          // Delete action
          AppButton.secondary(
            label: 'budget_plans.delete_spending'.tr,
            icon: Icons.delete_outline,
            isFullWidth: true,
            onPressed: () async {
              final confirmed = await _confirmDelete(
                context,
                message: 'budget_plans.delete_spending_msg'.tr,
              );
              if (confirmed == true && context.mounted) {
                context.read<BudgetPlanDetailBloc>().add(
                  DeleteSpending(transaction.id),
                );
                Navigator.pop(context);
              }
            },
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared helpers
// ---------------------------------------------------------------------------

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: WiseSpendsColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: WiseSpendsColors.textHint,
                  ),
                ),
                Text(value, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteSlideBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.secondary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppSpacing.xl),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  final IconData icon;
  final String messageKey;

  const _EmptyTransactions({required this.icon, required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: WiseSpendsColors.textHint),
          const SizedBox(height: AppSpacing.md),
          Text(
            messageKey.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared delete confirmation dialog
Future<bool?> _confirmDelete(BuildContext context, {required String message}) {
  return showDeleteDialog(
    context: context,
    title: 'general.delete'.tr,
    message: message,
    deleteText: 'general.delete'.tr,
    cancelText: 'general.cancel'.tr,
  );
}

// =============================================================================
// Charts tab
// =============================================================================

class _ChartsTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const _ChartsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    // Calculate totals with overflow protection
    final totalDeposited = state.deposits.fold<double>(0.0, (s, d) {
      final sum = s + d.amount;
      return sum.isInfinite ? double.maxFinite : sum;
    });
    final totalSpent = state.transactions.fold<double>(0.0, (s, t) {
      final sum = s + t.amount;
      return sum.isInfinite ? double.maxFinite : sum;
    });

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
      byVendor[key] = (byVendor[key] ?? 0) + t.amount;
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

/// Tab indices for [BudgetPlanDetailScreen].
enum _DetailTab {
  overview(0),
  items(1),
  transactions(2),
  charts(3);

  const _DetailTab(this.tabIndex);
  final int tabIndex;

  static _DetailTab fromTabIndex(int index) => _DetailTab.values.firstWhere(
    (t) => t.tabIndex == index,
    orElse: () => _DetailTab.overview,
  );
}

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
    return AnimatedBuilder(
      animation: tabController,
      builder: (context, _) {
        final tab = _DetailTab.fromTabIndex(tabController.index);

        return switch (tab) {
          _DetailTab.overview => const SizedBox.shrink(),

          // Items tab manages its own FAB via a Stack — hide this one.
          _DetailTab.items => const SizedBox.shrink(),

          // Transactions tab — add a spending entry.
          _DetailTab.transactions => SpeedDialFab(
            actions: [
              SpeedDialAction(
                label: 'budget_plans.add_deposit'.tr,
                icon: Icons.add_circle_outline,
                backgroundColor: WiseSpendsColors.success,
                heroTag: 'fab_deposit',
                onPressed: onDeposit,
              ),
              SpeedDialAction(
                label: 'budget_plans.add_spending'.tr,
                icon: Icons.remove_circle_outline,
                backgroundColor: WiseSpendsColors.secondary,
                heroTag: 'fab_spending',
                onPressed: onSpending,
              ),
            ],
          ),

          _DetailTab.charts => const SizedBox.shrink(),
        };
      },
    );
  }
}
