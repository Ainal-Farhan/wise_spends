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

// ─────────────────────────────────────────────────────────────────────────────
// Root tab
// ─────────────────────────────────────────────────────────────────────────────

/// Transactions tab widget - displays deposits and spending lists.
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
          TransactionSummaryStrip(state: state),
          const SizedBox(height: AppSpacing.xxl),
          _DepositsList(deposits: state.deposits),
          const SizedBox(height: AppSpacing.xxl),
          _TransactionsList(transactions: state.transactions),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Summary strip
// ─────────────────────────────────────────────────────────────────────────────

/// Summary strip: three metric cells + a spending progress bar.
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
    final spentRatio = totalDeposits > 0
        ? (totalTransactions / totalDeposits).clamp(0.0, 1.0)
        : 0.0;
    final spentPct = (spentRatio * 100).toStringAsFixed(0);
    final remainPct = (100 - spentRatio * 100).toStringAsFixed(0);

    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        children: [
          // ── Three metric cells ──
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SummaryCell(
                  label: 'budget_plans.deposits'.tr,
                  value: fmt.format(totalDeposits),
                  icon: Icons.add_circle_outline,
                  color: WiseSpendsColors.success,
                ),
                const SummaryDivider(),
                SummaryCell(
                  label: 'budget_plans.transactions'.tr,
                  value: fmt.format(totalTransactions),
                  icon: Icons.money_off_csred,
                  color: WiseSpendsColors.secondary,
                ),
                const SummaryDivider(),
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
          ),

          // ── Divider ──
          const Divider(height: 1),

          // ── Spending progress bar ──
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$spentPct% spent',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                    Text(
                      '$remainPct% remaining',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: WiseSpendsColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: spentRatio,
                    backgroundColor: WiseSpendsColors.error.withValues(
                      alpha: 0.15,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      WiseSpendsColors.success,
                    ),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared summary sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Single metric cell inside the summary strip.
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

/// Thin vertical divider between summary cells.
class SummaryDivider extends StatelessWidget {
  const SummaryDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 40, color: WiseSpendsColors.divider);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pressable card mixin
// ─────────────────────────────────────────────────────────────────────────────

/// A StatefulWidget that shrinks slightly on press.
/// Extend this instead of StatelessWidget for tappable cards.
abstract class _PressableCard extends StatefulWidget {
  const _PressableCard();
}

abstract class _PressableCardState<T extends _PressableCard> extends State<T> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);
  void _onTapUp(TapUpDetails _) => setState(() => _pressed = false);
  void _onTapCancel() => setState(() => _pressed = false);

  Widget buildCard(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: buildCard(context),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deposit widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Deposit card with press-to-scale animation.
class _DepositCard extends _PressableCard {
  final BudgetPlanDepositEntity deposit;

  const _DepositCard({required this.deposit});

  @override
  _DepositCardState createState() => _DepositCardState();
}

class _DepositCardState extends _PressableCardState<_DepositCard> {
  @override
  Widget buildCard(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '+RM ', decimalDigits: 2);

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
          widget.deposit.sourceDisplayName,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          widget.deposit.note ?? '',
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
              fmt.format(widget.deposit.amount),
              style: AppTextStyles.amountSmall.copyWith(
                color: WiseSpendsColors.success,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd MMM y').format(widget.deposit.depositDate),
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

/// Empty state for the deposits list.
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

/// Scrollable deposits list with section header.
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

// ─────────────────────────────────────────────────────────────────────────────
// Transaction widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Transaction card with press-to-scale animation.
class _TransactionCard extends _PressableCard {
  final BudgetPlanTransactionEntity transaction;

  const _TransactionCard({required this.transaction});

  @override
  _TransactionCardState createState() => _TransactionCardState();
}

class _TransactionCardState extends _PressableCardState<_TransactionCard> {
  @override
  Widget buildCard(BuildContext context) {
    final fmt = NumberFormat.currency(symbol: '-RM ', decimalDigits: 2);

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
          widget.transaction.vendor ?? 'budget_plans.transaction'.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          widget.transaction.description ?? '',
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
              fmt.format(widget.transaction.amount),
              style: AppTextStyles.amountSmall.copyWith(
                color: WiseSpendsColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              DateFormat('dd MMM y').format(widget.transaction.transactionDate),
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

/// Empty state for the transactions list.
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

/// Scrollable transactions list with section header.
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
