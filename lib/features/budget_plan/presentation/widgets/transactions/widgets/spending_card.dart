import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/helpers/transaction_card_config.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/detail_row.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/sheet_drag_handle.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/transaction_card.dart';
import 'package:wise_spends/shared/components/section_header.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Spending card
// ─────────────────────────────────────────────────────────────────────────────

class SpendingCard extends StatelessWidget {
  const SpendingCard({super.key, required this.transaction});

  final BudgetPlanTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BudgetPlanDetailBloc>();
    final fmt = NumberFormat('#,##0.00', 'en_US');

    final hasReceipt = transaction.receiptImagePath?.isNotEmpty == true;

    final config = TransactionCardConfig(
      accentColor: Theme.of(context).colorScheme.secondary,
      icon: Icons.north_outlined,
      amountPrefix: '- RM ',
      amountLabel: '- RM ${fmt.format(transaction.amount)}',
      deleteConfirmKey: 'budget_plans.delete_spending_msg',
      onDelete: () => bloc.add(DeleteSpending(transaction.id)),
    );

    // Receipt badge shown in the trailing column when a receipt exists
    final receiptBadge = hasReceipt
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_outlined,
                  size: 11,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 3),
                Text(
                  'budget_plans.receipt'.tr,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          )
        : null;

    // Subtitle: date  ·  vendor (if any)
    final subtitleParts = [
      DateFormat('EEE, MMM d, y').format(transaction.transactionDate),
      if (transaction.vendor != null && transaction.vendor!.isNotEmpty)
        transaction.vendor!,
    ];

    return TransactionCard(
      config: config,
      dismissibleKey: Key('spending_${transaction.id}'),
      title: transaction.description ?? 'budget_plans.spending'.tr,
      subtitle: subtitleParts.join('  ·  '),
      badge: receiptBadge,
      onTap: () => _showDetail(context),
      context: context,
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetPlanDetailBloc>(),
        child: SpendingDetailSheet(transaction: transaction),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Spending detail sheet
// ─────────────────────────────────────────────────────────────────────────────

class SpendingDetailSheet extends StatelessWidget {
  const SpendingDetailSheet({super.key, required this.transaction});

  final BudgetPlanTransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');
    final hasReceipt = transaction.receiptImagePath?.isNotEmpty == true;

    return SafeArea(
      child: SingleChildScrollView(
        // isScrollControlled=true on the sheet means it can expand to fill
        // the screen; SingleChildScrollView handles tall receipts gracefully.
        padding: EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SheetDragHandle(),
            const SizedBox(height: AppSpacing.xxl),

            // ── Header ──
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.north_outlined,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    transaction.description ?? 'budget_plans.spending'.tr,
                    style: AppTextStyles.h2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  '- RM ${fmt.format(transaction.amount)}',
                  style: AppTextStyles.amountMedium.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxl),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.lg),

            // ── Details ──
            DetailRow(
              icon: Icons.calendar_today_outlined,
              label: 'general.date'.tr,
              value: DateFormat(
                'EEEE, MMMM d, y',
              ).format(transaction.transactionDate),
            ),
            if (transaction.vendor != null && transaction.vendor!.isNotEmpty)
              DetailRow(
                icon: Icons.store_outlined,
                label: 'budget_plans.vendor'.tr,
                value: transaction.vendor!,
              ),

            // ── Receipt ──
            if (hasReceipt) ...[
              const SizedBox(height: AppSpacing.lg),
              SectionHeaderCompact(title: 'budget_plans.receipt'.tr),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: Image.asset(
                  transaction.receiptImagePath!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _ReceiptErrorPlaceholder(),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}

// ── Receipt error placeholder ─────────────────────────────────────────────────

class _ReceiptErrorPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.broken_image_outlined,
              color: Theme.of(context).colorScheme.outline,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'budget_plans.receipt_unavailable'.tr,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
