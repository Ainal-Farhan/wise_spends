import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/presentation/blocs/payee/payee_bloc.dart';
import 'package:wise_spends/presentation/blocs/payee/payee_event.dart';
import 'package:wise_spends/presentation/blocs/payee/payee_state.dart';
import 'package:wise_spends/data/repositories/expense/impl/payee_repository.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';

/// Payee Management Screen
class PayeeManagementScreen extends StatelessWidget {
  const PayeeManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          PayeeBloc(PayeeRepository())..add(const LoadPayees()),
      child: const _PayeeManagementScreenContent(),
    );
  }
}

class _PayeeManagementScreenContent extends StatelessWidget {
  const _PayeeManagementScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('payees.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddPayeeDialog(context),
            tooltip: 'Add Payee',
          ),
        ],
      ),
      body: BlocConsumer<PayeeBloc, PayeeState>(
        listener: (context, state) {
          if (state is PayeeSaved || state is PayeeDeleted) {
            final message = state is PayeeSaved
                ? state.message
                : state is PayeeDeleted
                ? state.message
                : '';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(message),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            context.read<PayeeBloc>().add(const LoadPayees());
          } else if (state is PayeeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PayeeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PayeesLoaded) {
            final payees = state.payees;

            if (payees.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PayeeBloc>().add(const LoadPayees());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: payees.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final payee = payees[index];
                  return _buildPayeeCard(context, payee);
                },
              ),
            );
          } else if (state is PayeeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text('payees.something_wrong'.tr, style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: AppButton.primary(
                      label: 'Retry',
                      onPressed: () {
                        context.read<PayeeBloc>().add(const LoadPayees());
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('payees.no_payees'.tr, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add payees to manage your third-party payment recipients',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Add Payee',
                icon: Icons.add,
                onPressed: () => _showAddPayeeDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayeeCard(BuildContext context, PayeeVO payee) {
    return AppCard(
      onTap: () => _showEditPayeeDialog(context, payee),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payee.name ?? 'Unnamed Payee',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payee.bankName != null && payee.bankName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    payee.bankName!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (payee.accountNumber != null &&
                    payee.accountNumber!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Acc: ${payee.accountNumber}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditPayeeDialog(context, payee);
              } else if (value == 'delete') {
                _confirmDeletePayee(context, payee);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('payees.edit'.tr),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddPayeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final accountController = TextEditingController();
    final bankController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Add Payee',
          icon: Icons.person_add_outlined,
          iconColor: AppColors.primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Name',
                controller: nameController,
                hint: 'e.g., ABC Insurance Co.',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Account Number',
                controller: accountController,
                hint: 'e.g., 1234567890',
                prefixIcon: Icons.numbers,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bank Name',
                controller: bankController,
                hint: 'e.g., Maybank',
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Note (Optional)',
                controller: noteController,
                hint: 'e.g., PayNow UEN, DuitNow ID',
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Add',
              isDefault: true,
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('payees.enter_name'.tr),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final payee = PayeeVO()
                  ..name = name
                  ..accountNumber = accountController.text.trim().isEmpty
                      ? null
                      : accountController.text.trim()
                  ..bankName = bankController.text.trim().isEmpty
                      ? null
                      : bankController.text.trim()
                  ..note = noteController.text.trim().isEmpty
                      ? null
                      : noteController.text.trim();

                context.read<PayeeBloc>().add(SavePayee(payee));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPayeeDialog(BuildContext context, PayeeVO payee) {
    final nameController = TextEditingController(text: payee.name ?? '');
    final accountController = TextEditingController(
      text: payee.accountNumber ?? '',
    );
    final bankController = TextEditingController(text: payee.bankName ?? '');
    final noteController = TextEditingController(text: payee.note ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Edit Payee',
          icon: Icons.edit_note,
          iconColor: AppColors.tertiary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Name',
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Account Number',
                controller: accountController,
                prefixIcon: Icons.numbers,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Bank Name',
                controller: bankController,
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Note',
                controller: noteController,
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Update',
              isDefault: true,
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('payees.enter_name'.tr),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                payee.name = name;
                payee.accountNumber = accountController.text.trim().isEmpty
                    ? null
                    : accountController.text.trim();
                payee.bankName = bankController.text.trim().isEmpty
                    ? null
                    : bankController.text.trim();
                payee.note = noteController.text.trim().isEmpty
                    ? null
                    : noteController.text.trim();

                context.read<PayeeBloc>().add(SavePayee(payee));
                Navigator.pop(dialogContext);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeletePayee(BuildContext context, PayeeVO payee) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete Payee?',
          message:
              'Are you sure you want to delete this payee? This cannot be undone.',
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Delete',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<PayeeBloc>().add(DeletePayee(payee.id!));
              },
            ),
          ],
        ),
      ),
    );
  }
}
