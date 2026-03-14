import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class HomeQuickActions extends StatelessWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('home.quick_actions'.tr, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        _ActionGrid(
          items: [
            _QuickActionData(
              icon: TransactionType.income.icon,
              label: TransactionType.income.label,
              color: colorScheme.primary,
              onTap: (ctx) =>
                  _navigateToAddTransaction(ctx, TransactionType.income),
            ),
            _QuickActionData(
              icon: TransactionType.expense.icon,
              label: TransactionType.expense.label,
              color: colorScheme.secondary,
              onTap: (ctx) =>
                  _navigateToAddTransaction(ctx, TransactionType.expense),
            ),
            _QuickActionData(
              icon: Icons.swap_horiz_rounded,
              label: 'home.transfer'.tr,
              color: colorScheme.tertiary,
              onTap: (ctx) =>
                  _navigateToAddTransaction(ctx, TransactionType.transfer),
            ),
            _QuickActionData(
              icon: Icons.savings_rounded,
              label: 'Savings',
              color: colorScheme.tertiary,
              onTap: (ctx) => Navigator.pushNamed(ctx, AppRoutes.savings),
            ),
            _QuickActionData(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Budgets',
              color: colorScheme.primary,
              onTap: (ctx) =>
                  Navigator.pushNamed(ctx, AppRoutes.budgetPlansList),
            ),
            _QuickActionData(
              icon: Icons.task_alt_rounded,
              label: 'home.tasks'.tr,
              color: colorScheme.tertiary,
              onTap: (ctx) =>
                  Navigator.pushNamed(ctx, AppRoutes.commitmentTask),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToAddTransaction(BuildContext context, TransactionType type) {
    AppRouter.navigateTo(
      context,
      AppRoutes.addTransaction,
      arguments: AddTransactionArgs(preselectedType: type),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  final List<_QuickActionData> items;

  const _ActionGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    // Split into rows of 3
    final rows = <List<_QuickActionData>>[];
    for (var i = 0; i < items.length; i += 3) {
      rows.add(items.sublist(i, i + 3 > items.length ? items.length : i + 3));
    }

    return Column(
      children: rows.map((row) {
        return Padding(
          padding: rows.indexOf(row) > 0
              ? const EdgeInsets.only(top: AppSpacing.md)
              : EdgeInsets.zero,
          child: Row(
            children: row
                .asMap()
                .entries
                .map((entry) {
                  return [
                    if (entry.key > 0) const SizedBox(width: AppSpacing.md),
                    Expanded(child: _QuickActionTile(data: entry.value)),
                  ];
                })
                .expand((e) => e)
                .toList(),
          ),
        );
      }).toList(),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final _QuickActionData data;

  const _QuickActionTile({required this.data});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => data.onTap(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                data.color.withValues(alpha: 0.12),
                data.color.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: data.color.withValues(alpha: 0.25)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.lg,
              horizontal: AppSpacing.sm,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: data.color,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 22),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  data.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: data.color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickActionData {
  final IconData icon;
  final String label;
  final Color color;
  final void Function(BuildContext) onTap;

  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
