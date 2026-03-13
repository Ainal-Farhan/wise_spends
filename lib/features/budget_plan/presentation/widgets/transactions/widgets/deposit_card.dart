import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_deposit_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/helpers/transaction_card_config.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/detail_row.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/sheet_drag_handle.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/transaction_card.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Deposit card
// ─────────────────────────────────────────────────────────────────────────────

class DepositCard extends StatelessWidget {
  const DepositCard({super.key, required this.deposit});

  final BudgetPlanDepositEntity deposit;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<BudgetPlanDetailBloc>();
    final fmt = NumberFormat('#,##0.00', 'en_US');

    final config = TransactionCardConfig(
      accentColor: WiseSpendsColors.success,
      icon: _sourceIcon(deposit.source),
      amountPrefix: '+ RM ',
      amountLabel: '+ RM ${fmt.format(deposit.amount)}',
      deleteConfirmKey: 'budget_plans.delete_deposit_msg',
      onDelete: () => bloc.add(DeleteDeposit(deposit.id)),
    );

    return TransactionCard(
      config: config,
      dismissibleKey: Key('deposit_${deposit.id}'),
      title: deposit.sourceDisplayName,
      subtitle: DateFormat('EEE, MMM d, y').format(deposit.depositDate),
      note: deposit.note,
      onTap: () => _showDetail(context),
      context: context,
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
        return Icons.south_outlined;
    }
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      builder: (_) => DepositDetailSheet(deposit: deposit),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deposit detail sheet
// ─────────────────────────────────────────────────────────────────────────────

class DepositDetailSheet extends StatelessWidget {
  const DepositDetailSheet({super.key, required this.deposit});

  final BudgetPlanDepositEntity deposit;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'en_US');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
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
                    color: WiseSpendsColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.south_outlined,
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
                  '+ RM ${fmt.format(deposit.amount)}',
                  style: AppTextStyles.amountMedium.copyWith(
                    color: WiseSpendsColors.success,
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
              value: DateFormat('EEEE, MMMM d, y').format(deposit.depositDate),
            ),
            if (deposit.note != null && deposit.note!.isNotEmpty)
              DetailRow(
                icon: Icons.note_outlined,
                label: 'general.note'.tr,
                value: deposit.note!,
              ),

            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
