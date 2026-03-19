import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_revoke_entity.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_state.dart';
import 'package:wise_spends/features/transaction/presentation/screens/transaction_form_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

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
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
          if (state is TransactionRevoked) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('transaction.action.revoke_success'.tr),
                  ],
                ),
                backgroundColor: Theme.of(context).colorScheme.primary,
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
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is! TransactionDetailLoaded) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () =>
                    _navigateToEdit(context, state.transaction, state),
                tooltip: 'general.edit'.tr,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteConfirmation(context),
            tooltip: 'general.delete'.tr,
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Use the enriched detail state that carries resolved names
          if (state is TransactionDetailLoaded) {
            return _buildContent(context, state);
          }

          if (state is TransactionError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppButton.primary(
                      label: 'general.go_back'.tr,
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
          _buildAmountCard(context, tx),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoCard(context, state),
          const SizedBox(height: AppSpacing.lg),
          _buildDetailsCard(context, state),
          const SizedBox(height: AppSpacing.xxl),
          _buildActionButtons(context, tx, state),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amount hero card
  // ---------------------------------------------------------------------------

  Widget _buildAmountCard(BuildContext context, TransactionEntity tx) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            tx.type.getBackgroundColor(context),
            tx.type.getBackgroundColor(context).withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: tx.type.getBackgroundColor(context).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(tx.type.icon, size: 48, color: Colors.white),
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
              tx.type.label,
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

  Widget _buildInfoCard(BuildContext context, TransactionDetailLoaded state) {
    final tx = state.transaction;
    final isRevoked = tx.isRevoked;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: tx.type.getBackgroundColor(context).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              state.categoryIcon,
              color: tx.type.getBackgroundColor(context),
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        tx.title,
                        style: AppTextStyles.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isRevoked) ...[
                      const SizedBox(width: AppSpacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.block,
                              size: 14,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'transaction.detail.revoked'.tr,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.label_outline,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        state.categoryName,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'transaction.detail.transaction_details'.tr,
            style: AppTextStyles.bodySemiBold.copyWith(fontSize: 18),
          ),
          const SizedBox(height: AppSpacing.md),

          // Date AND time
          _buildDetailRow(
            context,
            icon: Icons.calendar_today_rounded,
            label: 'transaction.add.date_time'.tr,
            value: _formatDateTime(tx.date),
          ),

          // Account — resolved saving name, not UUID
          _buildDetailRow(
            context,
            icon: Icons.account_balance_rounded,
            label: isTransfer
                ? 'transaction.field.source_account'.tr
                : 'transaction.field.account'.tr,
            value: state.accountName,
          ),

          // Transfer: target account name
          if ((isTransfer || isCommitment) && state.targetAccountName != null)
            _buildDetailRow(
              context,
              icon: Icons.account_balance_outlined,
              label: 'transaction.field.destination_account'.tr,
              value: state.targetAccountName!,
            ),

          // Payee info — only for third-party commitment payments
          if (state.payeeVO?.name != null)
            _buildDetailRow(
              context,
              icon: Icons.person_outline,
              label: 'transaction.add.payee'.tr,
              value: state.payeeVO!.name!,
            ),
          if (state.payeeVO?.bankName != null)
            _buildDetailRow(
              context,
              icon: Icons.account_balance_wallet_outlined,
              label: 'transaction.field.bank'.tr,
              value: state.payeeVO!.bankName!,
            ),
          if (state.payeeVO?.accountNumber != null)
            _buildDetailRow(
              context,
              icon: Icons.credit_card_outlined,
              label: 'transaction.field.account_number'.tr,
              value: state.payeeVO!.accountNumber!,
            ),

          // Commitment task reference
          if (state.commitmentTaskName != null)
            _buildDetailRow(
              context,
              icon: Icons.task_alt,
              label: 'commitment.task'.tr,
              value: state.commitmentTaskName!,
            ),

          if (tx.note != null && tx.note!.isNotEmpty)
            _buildDetailRow(
              context,
              icon: Icons.note_rounded,
              label: 'transaction.add.note'.tr,
              value: tx.note!,
              isMultiline: true,
            ),

          Divider(color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: AppSpacing.sm),

          // Transaction ID — small, secondary
          _buildDetailRow(
            context,
            icon: Icons.tag,
            label: 'transaction.field.transaction_id'.tr,
            value: tx.id,
            valueStyle: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: 'monospace',
            ),
          ),

          // Revoke information - shown only if transaction is revoked
          if (tx.isRevoked && tx.revoke != null) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: AppSpacing.md),
            _buildRevokeInfoCard(context, tx.revoke!),
          ],
        ],
      ),
    );
  }

  Widget _buildRevokeInfoCard(
    BuildContext context,
    TransactionRevokeEntity revoke,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.errorContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.block,
                size: 20,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'transaction.detail.revoked_status'.tr,
                style: AppTextStyles.bodySemiBold.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildRevokeDetailRow(
            context,
            icon: Icons.info_outline,
            label: 'transaction.detail.revoke_reason'.tr,
            value: revoke.reason,
            isMultiline: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildRevokeDetailRow(
            context,
            icon: Icons.access_time,
            label: 'transaction.detail.revoked_at'.tr,
            value: _formatDateTime(revoke.revokedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildRevokeDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                value,
                style: AppTextStyles.bodySmall,
                maxLines: isMultiline ? null : 1,
                overflow: isMultiline ? null : TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
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
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  Widget _buildActionButtons(
    BuildContext context,
    TransactionEntity tx,
    TransactionDetailLoaded state,
  ) {
    final isRevoked = tx.isRevoked;

    return Column(
      children: [
        if (!isRevoked) ...[
          AppButton.primary(
            label: 'transaction.action.edit'.tr,
            onPressed: () => _navigateToEdit(context, tx, state),
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.destructive(
            label: 'transaction.action.delete'.tr,
            onPressed: () => _showDeleteConfirmation(context),
            isFullWidth: true,
          ),
          const SizedBox(height: AppSpacing.md),
          AppButton.secondary(
            label: 'transaction.action.revoke'.tr,
            onPressed: () => _showRevokeDialog(context),
            isFullWidth: true,
            icon: Icons.block,
          ),
        ] else ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.errorContainer.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.error.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'transaction.detail.revoked_status'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _navigateToEdit(
    BuildContext context,
    TransactionEntity tx,
    TransactionDetailLoaded state,
  ) {
    // Extract time from transaction date if it's not midnight
    final TimeOfDay? storedTime = tx.date.hour == 0 && tx.date.minute == 0
        ? null
        : TimeOfDay(hour: tx.date.hour, minute: tx.date.minute);

    Navigator.pushNamed(
      context,
      AppRoutes.editTransaction,
      arguments: TransactionFormScreenArgs(
        editingTransactionId: tx.id,
        preselectedType: tx.type,
        existingTransaction: tx,
        existingCategory: state.categoryEntity,
        existingPayee: state.payeeVO,
        existingTime: storedTime,
      ),
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

  void _showRevokeDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final transactionBloc = context.read<TransactionBloc>();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.block, color: Theme.of(context).colorScheme.error),
              const SizedBox(width: AppSpacing.sm),
              Text('transaction.action.revoke_title'.tr),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'transaction.action.revoke_confirm'.tr,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'transaction.action.revoke_reason_label'.tr,
                style: AppTextStyles.bodySemiBold,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  hintText: 'transaction.action.revoke_reason_hint'.tr,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.edit_note),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('general.cancel'.tr),
            ),
            FilledButton.icon(
              onPressed: () {
                final reason = reasonController.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('transaction.action.revoke_reason_hint'.tr),
                      backgroundColor: Theme.of(
                        dialogContext,
                      ).colorScheme.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext);
                transactionBloc.add(
                  RevokeTransactionEvent(
                    transactionId: transactionId,
                    reason: reason,
                  ),
                );
              },
              icon: const Icon(Icons.block),
              label: Text('transaction.action.revoke'.tr),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Full date + time, e.g. "Friday, 6 March 2026 at 3:45 PM"
  String _formatDateTime(DateTime date) {
    // Use locale-aware date and time formatting
    final dateFormat = DateFormat.yMMMMEEEEd();
    final timeFormat = DateFormat.jm();
    return '${dateFormat.format(date)} ${'transaction.detail.at'.tr} ${timeFormat.format(date)}';
  }
}
