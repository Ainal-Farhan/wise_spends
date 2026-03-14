import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeBalanceSection extends StatelessWidget {
  final double totalBalance;
  final double totalIncome;
  final double totalExpenses;

  const HomeBalanceSection({
    super.key,
    required this.totalBalance,
    required this.totalIncome,
    required this.totalExpenses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _TotalBalanceCard(totalBalance: totalBalance),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _IncomeExpenseCard(
                icon: TransactionType.income.icon,
                label: TransactionType.income.label,
                value: _formatCurrency(totalIncome),
                color: TransactionType.income.getColor(context),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _IncomeExpenseCard(
                icon: TransactionType.expense.icon,
                label: TransactionType.expense.label,
                value: _formatCurrency(totalExpenses),
                color: TransactionType.expense.getColor(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatCurrency(double amount) =>
      NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(amount);
}

class _TotalBalanceCard extends StatelessWidget {
  final double totalBalance;

  const _TotalBalanceCard({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard.gradient(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [colorScheme.primary, colorScheme.primaryContainer],
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_rounded,
                color: Colors.white70,
                size: AppIconSize.lg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'general.balance'.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _BalanceTrendChip(totalBalance: totalBalance),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 2,
            ).format(totalBalance),
            style: AppTextStyles.balanceDisplay,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'transaction.history.this_month'.tr,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceTrendChip extends StatelessWidget {
  final double totalBalance;

  const _BalanceTrendChip({required this.totalBalance});

  @override
  Widget build(BuildContext context) {
    final isPositive = totalBalance >= 0;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.greenAccent : Colors.redAccent).withValues(
          alpha: 0.2,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: (isPositive ? Colors.greenAccent : Colors.redAccent)
              .withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? Colors.greenAccent : Colors.redAccent,
            size: 12,
          ),
          const SizedBox(width: 2),
          Text(
            isPositive ? 'transaction.surplus'.tr : 'transaction.deficit'.tr,
            style: TextStyle(
              color: isPositive ? Colors.greenAccent : Colors.redAccent,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _IncomeExpenseCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: AppIconSize.md),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HomeBalanceSectionShimmer extends StatelessWidget {
  const HomeBalanceSectionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        ShimmerBalanceCard(isHero: true),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(child: ShimmerBalanceCard()),
            SizedBox(width: AppSpacing.md),
            Expanded(child: ShimmerBalanceCard()),
          ],
        ),
      ],
    );
  }
}
