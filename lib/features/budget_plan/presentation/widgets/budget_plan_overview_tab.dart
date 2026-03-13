import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/shared/components/section_header.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';
import 'budget_plan_milestone_card.dart';
import 'budget_plan_linked_account_card.dart';
import 'budget_plan_empty_section.dart';
import 'budget_plan_linked_accounts_empty.dart';
import 'budget_plan_linked_accounts_total_banner.dart';
import 'budget_plan_progress_body.dart';
import 'budget_plan_link_account_sheet.dart';

/// Overview tab widget - displays plan progress, milestones, and linked accounts
class BudgetPlanOverviewTab extends StatelessWidget {
  final BudgetPlanEntity plan;
  final List<dynamic> milestones;
  final List<dynamic> linkedAccounts;
  final VoidCallback onAddDeposit;
  final VoidCallback onAddSpending;
  final ValueChanged<String> onAddMilestone;
  final void Function(String milestoneId, String planId) onCompleteMilestone;
  final void Function(String milestoneId, String planId) onDeleteMilestone;
  final void Function(String accountId, String planId) onUnlinkAccount;

  const BudgetPlanOverviewTab({
    super.key,
    required this.plan,
    required this.milestones,
    required this.linkedAccounts,
    required this.onAddDeposit,
    required this.onAddSpending,
    required this.onAddMilestone,
    required this.onCompleteMilestone,
    required this.onDeleteMilestone,
    required this.onUnlinkAccount,
  });

  @override
  Widget build(BuildContext context) {
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
            collapsibleBody: ProgressBody(plan: plan, color: healthColor),
            learnMoreLabel: 'general.details'.tr,
            learnLessLabel: 'general.less'.tr,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Quick actions
          _QuickActionsSection(
            onAddDeposit: onAddDeposit,
            onAddSpending: onAddSpending,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Milestones
          _buildMilestonesSection(context),

          const SizedBox(height: AppSpacing.xxl),

          // Linked accounts
          _buildLinkedAccountsSection(context),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildMilestonesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'budget_plans.milestones'.tr,
          trailing: TextButton.icon(
            onPressed: () => onAddMilestone(plan.id),
            icon: const Icon(Icons.add, size: AppIconSize.sm),
            label: Text('budget_plans.add_milestone'.tr),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (milestones.isEmpty)
          EmptySection(
            icon: Icons.flag_outlined,
            messageKey: 'budget_plans.no_milestones',
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: milestones.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) => MilestoneCard(
              milestone: milestones[i],
              planId: plan.id,
              onComplete: onCompleteMilestone,
              onDelete: onDeleteMilestone,
            ),
          ),
      ],
    );
  }

  Widget _buildLinkedAccountsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'budget_plans.linked_accounts'.tr,
          trailing: TextButton.icon(
            onPressed: () => _showLinkAccountSheet(context),
            icon: const Icon(Icons.add_link, size: AppIconSize.sm),
            label: Text('budget_plans.link_account'.tr),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'budget_plans.linked_accounts_desc'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (linkedAccounts.isEmpty)
          LinkedAccountsEmpty(onLink: () => _showLinkAccountSheet(context))
        else
          Column(
            children: [
              LinkedAccountsTotalBanner(
                accounts: linkedAccounts.cast(),
                planTarget: plan.targetAmount,
              ),
              const SizedBox(height: AppSpacing.md),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: linkedAccounts.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => LinkedAccountCard(
                  account: linkedAccounts[i],
                  planId: plan.id,
                  onUnlink: onUnlinkAccount,
                ),
              ),
            ],
          ),
      ],
    );
  }

  void _showLinkAccountSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: LinkAccountSheet(planId: plan.id),
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
// Quick Actions Section
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
                  icon: Icons.money_off_csred,
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

// =============================================================================
// Action Card
// =============================================================================

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              sublabel,
              style: AppTextStyles.bodySmall.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
