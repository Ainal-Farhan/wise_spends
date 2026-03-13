import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_state.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/deposit_card.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/spending_card.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/transaction_empty.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/transaction_summary_strip.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Root widget for the Transactions tab.
class BudgetPlanTransactionsTab extends StatelessWidget {
  const BudgetPlanTransactionsTab({super.key, required this.state});

  final BudgetPlanDetailLoaded state;

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

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Summary strip with progress bar
          TransactionSummaryStrip(
            totalDeposited: totalDeposited,
            totalSpent: totalSpent,
            net: totalDeposited - totalSpent,
          ),

          // Sub-tab bar
          TabBar(
            tabs: [
              Tab(
                icon: const Icon(Icons.south_outlined, size: 16),
                text: 'budget_plans.deposits'.tr,
              ),
              Tab(
                icon: const Icon(Icons.north_outlined, size: 16),
                text: 'budget_plans.spending'.tr,
              ),
            ],
          ),

          // Tab content
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

// ─────────────────────────────────────────────────────────────────────────────
// Deposits list
// ─────────────────────────────────────────────────────────────────────────────

class _DepositsList extends StatelessWidget {
  const _DepositsList({required this.deposits});

  final List deposits;

  @override
  Widget build(BuildContext context) {
    if (deposits.isEmpty) {
      return const TransactionEmpty(
        icon: Icons.savings_outlined,
        messageKey: 'budget_plans.no_deposits',
        subMessageKey: 'budget_plans.no_deposits_hint',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: deposits.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => DepositCard(deposit: deposits[i]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending list
// ─────────────────────────────────────────────────────────────────────────────

class _SpendingList extends StatelessWidget {
  const _SpendingList({required this.transactions});

  final List transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const TransactionEmpty(
        icon: Icons.receipt_long_outlined,
        messageKey: 'budget_plans.no_spending',
        subMessageKey: 'budget_plans.no_spending_hint',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) => SpendingCard(transaction: transactions[i]),
    );
  }
}
