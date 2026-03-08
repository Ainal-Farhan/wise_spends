import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/router/route_arguments.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

class TransactionDetailScreen extends StatelessWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TransactionBloc(
        ctx.read<ITransactionRepository>(),
        ctx.read<ISavingRepository>(),
      )..add(LoadTransactionDetailEvent(transactionId)),
      child: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionDeleted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeLoggedIn,
              (context) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('transaction.detail.deleted'.tr),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: _TransactionDetailScreenContent(transactionId: transactionId),
      ),
    );
  }
}

class _TransactionDetailScreenContent extends StatelessWidget {
  final String transactionId;

  const _TransactionDetailScreenContent({required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('transaction.detail.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _navigateToEdit(context),
            tooltip: 'Edit',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'Delete',
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use the new enriched detail state that carries resolved names
          if (state is TransactionDetailLoaded) {
            return _buildContent(context, state);
          }

          // Fallback: plain loaded states without enriched data
          if (state is TransactionLoadedById) {
            return _buildContent(
              context,
              TransactionDetailLoaded(
                transaction: state.transaction,
                accountName: state.transaction.sourceAccountId,
                payeeVO: state.payeeVO,
                categoryName: state.transaction.categoryId ?? '',
                categoryIcon: CategoryIconMapper.getIconForCategory(
                  state.transaction.categoryId ?? '',
                ),
              ),
            );
          }

          if (state is TransactionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      label: 'Go Back',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionDetailLoaded state) {
    final tx = state.transaction;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAmountCard(tx),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoCard(state),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailsCard(context, state),
          const SizedBox(height: AppSpacing.xxl),
          _buildActionButtons(context, tx),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amount hero card
  // ---------------------------------------------------------------------------

  Widget _buildAmountCard(TransactionEntity tx) {
    final isIncome = tx.type == TransactionType.income;
    final isTransfer = tx.type == TransactionType.transfer;
    final isCommitment = tx.type == TransactionType.commitment;

    final Color baseColor = isTransfer || isCommitment
        ? AppColors.transfer
        : isIncome
        ? AppColors.income
        : AppColors.expense;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [baseColor, baseColor.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            isTransfer || isCommitment
                ? Icons.swap_horiz_rounded
                : isIncome
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            NumberFormat.currency(
              symbol: 'RM',
              decimalDigits: 2,
            ).format(tx.amount),
            style: AppTextStyles.amountXLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _typeLabel(tx.type),
              style: AppTextStyles.labelMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Info card — title + resolved category name + icon
  // ---------------------------------------------------------------------------

  Widget _buildInfoCard(TransactionDetailLoaded state) {
    final tx = state.transaction;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          // Category icon — resolved, not a UUID
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _typeColor(tx.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              state.categoryIcon,
              color: _typeColor(tx.type),
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.title,
                  style: AppTextStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                // Category name — resolved, not a UUID
                Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        state.categoryName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Details card — account name, datetime, note, payee, commitment, ID
  // ---------------------------------------------------------------------------

  Widget _buildDetailsCard(
    BuildContext context,
    TransactionDetailLoaded state,
  ) {
    final tx = state.transaction;
    final isTransfer = tx.type == TransactionType.transfer;
    final isCommitment = tx.type == TransactionType.commitment;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Details',
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date AND time
          _buildDetailRow(
            icon: Icons.calendar_today_rounded,
            label: 'Date & Time',
            value: _formatDateTime(tx.date),
          ),

          // Account — resolved saving name, not UUID
          _buildDetailRow(
            icon: Icons.account_balance_rounded,
            label: isTransfer ? 'Source Account' : 'Account',
            value: state.accountName,
          ),

          // Transfer: target account name
          if ((isTransfer || isCommitment) && state.targetAccountName != null)
            _buildDetailRow(
              icon: Icons.account_balance_outlined,
              label: 'Target Account',
              value: state.targetAccountName!,
            ),

          // Payee info — only for third-party commitment payments
          if (state.payeeVO?.name != null)
            _buildDetailRow(
              icon: Icons.person_outline,
              label: 'Payee',
              value: state.payeeVO!.name!,
            ),
          if (state.payeeVO?.bankName != null)
            _buildDetailRow(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Bank',
              value: state.payeeVO!.bankName!,
            ),
          if (state.payeeVO?.accountNumber != null)
            _buildDetailRow(
              icon: Icons.credit_card_outlined,
              label: 'Account No.',
              value: state.payeeVO!.accountNumber!,
            ),

          // Commitment task reference
          if (state.commitmentTaskName != null)
            _buildDetailRow(
              icon: Icons.task_alt,
              label: 'Commitment Task',
              value: state.commitmentTaskName!,
            ),

          if (tx.note != null && tx.note!.isNotEmpty)
            _buildDetailRow(
              icon: Icons.note_rounded,
              label: 'Note',
              value: tx.note!,
              isMultiline: true,
            ),

          Divider(color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Transaction ID — small, secondary
          _buildDetailRow(
            icon: Icons.tag,
            label: 'Transaction ID',
            value: tx.id,
            valueStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
    TextStyle? valueStyle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  value,
                  style: valueStyle ?? AppTextStyles.bodyMedium,
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Action buttons
  // ---------------------------------------------------------------------------

  Widget _buildActionButtons(BuildContext context, TransactionEntity tx) {
    return Column(
      children: [
        AppButton.primary(
          label: 'Edit Transaction',
          onPressed: () => _navigateToEdit(context),
          isFullWidth: true,
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton.destructive(
          label: 'Delete Transaction',
          onPressed: () => _showDeleteConfirmation(context),
          isFullWidth: true,
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _navigateToEdit(BuildContext context) {
    Navigator.pushNamed(
      context,
      AppRoutes.editTransaction,
      arguments: EditTransactionArgs(transactionId),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDeleteDialog(
      context: context,
      title: 'transaction.detail.delete_title'.tr,
      message: 'transaction.delete_confirm'.tr,
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      onDelete: () {
        context.read<TransactionBloc>().add(
          DeleteTransactionEvent(transactionId),
        );
      },
    );
  }

  /// Full date + time, e.g. "Friday, 6 March 2026 at 3:45 PM"
  String _formatDateTime(DateTime date) {
    return DateFormat("EEEE, d MMMM y 'at' h:mm a").format(date);
  }

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.commitment:
        return 'Commitment Payment';
    }
  }

  Color _typeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
      case TransactionType.commitment:
        return AppColors.transfer;
    }
  }
}
