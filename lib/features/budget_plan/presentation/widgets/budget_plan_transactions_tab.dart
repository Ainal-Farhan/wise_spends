import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_state.dart';
import 'package:wise_spends/shared/components/section_header.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Transactions tab widget - displays deposits and spending lists
class BudgetPlanTransactionsTab extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const BudgetPlanTransactionsTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction summary strip
          TransactionSummaryStrip(state: state),
          const SizedBox(height: AppSpacing.xxl),

          // Deposits
          _DepositsList(deposits: state.deposits),
          const SizedBox(height: AppSpacing.xxl),

          // Transactions
          _TransactionsList(transactions: state.transactions),
        ],
      ),
    );
  }
}

/// Transaction summary strip widget
class TransactionSummaryStrip extends StatelessWidget {
  final BudgetPlanDetailLoaded state;

  const TransactionSummaryStrip({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);
    final totalDeposits = state.deposits.fold<double>(
      0,
      (s, d) => s + d.amount,
    );
    final totalTransactions = state.transactions.fold<double>(
      0,
      (s, t) => s + t.amount,
    );
    final balance = totalDeposits - totalTransactions;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SummaryCell(
            label: 'budget_plans.deposits'.tr,
            value: fmt.format(totalDeposits),
            icon: Icons.add_circle_outline,
            color: WiseSpendsColors.success,
          ),
          Container(width: 1, height: 40, color: WiseSpendsColors.divider),
          SummaryCell(
            label: 'budget_plans.transactions'.tr,
            value: fmt.format(totalTransactions),
            icon: Icons.money_off_csred,
            color: WiseSpendsColors.secondary,
          ),
          Container(width: 1, height: 40, color: WiseSpendsColors.divider),
          SummaryCell(
            label: 'budget_plans.balance'.tr,
            value: fmt.format(balance),
            icon: Icons.account_balance_wallet,
            color: balance >= 0
                ? WiseSpendsColors.primary
                : WiseSpendsColors.error,
          ),
        ],
      ),
    );
  }
}

/// Summary cell widget
class SummaryCell extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const SummaryCell({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.amountMedium.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Summary divider widget
class SummaryDivider extends StatelessWidget {
  const SummaryDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: WiseSpendsColors.divider);
  }
}

/// Empty deposits widget
class _EmptyDeposits extends StatelessWidget {
  const _EmptyDeposits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: WiseSpendsColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'budget_plans.no_deposits'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Deposit card widget
class _DepositCard extends StatelessWidget {
  final BudgetPlanDepositEntity deposit;

  const _DepositCard({required this.deposit});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: WiseSpendsColors.success.withValues(alpha: 0.15),
          child: const Icon(
            Icons.check_circle,
            color: WiseSpendsColors.success,
            size: 20,
          ),
        ),
        title: Text(
          deposit.sourceDisplayName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          deposit.note ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              fmt.format(deposit.amount),
              style: AppTextStyles.amountSmall.copyWith(
                color: WiseSpendsColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd MMM y').format(deposit.depositDate),
              style: AppTextStyles.captionSmall.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}

/// Deposits list widget
class _DepositsList extends StatelessWidget {
  final List<BudgetPlanDepositEntity> deposits;

  const _DepositsList({required this.deposits});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'budget_plans.deposits'.tr),
        const SizedBox(height: AppSpacing.sm),
        if (deposits.isEmpty)
          const _EmptyDeposits()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: deposits.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) => _DepositCard(deposit: deposits[i]),
          ),
      ],
    );
  }
}

/// Transactions list widget
class _TransactionsList extends StatelessWidget {
  final List<BudgetPlanTransactionEntity> transactions;

  const _TransactionsList({required this.transactions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: 'budget_plans.transactions'.tr),
        const SizedBox(height: AppSpacing.sm),
        if (transactions.isEmpty)
          const _EmptyTransactions()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (_, i) =>
                _TransactionCard(transaction: transactions[i]),
          ),
      ],
    );
  }
}

/// Empty transactions widget
class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              color: WiseSpendsColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'budget_plans.no_transactions'.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction card widget
class _TransactionCard extends StatelessWidget {
  final BudgetPlanTransactionEntity transaction;

  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: WiseSpendsColors.error.withValues(alpha: 0.15),
          child: const Icon(
            Icons.money_off_csred,
            color: WiseSpendsColors.error,
            size: 20,
          ),
        ),
        title: Text(
          transaction.vendor ?? 'budget_plans.transaction'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          transaction.description ?? '',
          style: AppTextStyles.bodySmall.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              fmt.format(transaction.amount),
              style: AppTextStyles.amountSmall.copyWith(
                color: WiseSpendsColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd MMM y').format(transaction.transactionDate),
              style: AppTextStyles.captionSmall.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
