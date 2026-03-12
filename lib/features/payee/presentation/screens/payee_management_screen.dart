import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_bloc.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_event.dart';
import 'package:wise_spends/features/payee/presentation/bloc/payee_state.dart';
import 'package:wise_spends/features/commitment/data/repositories/impl/payee_repository.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

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
            tooltip: 'payees.add'.tr,
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
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
                  borderRadius: BorderRadius.circular(AppRadius.md),
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
              return EmptyStateWidget(
                icon: Icons.people_outline,
                title: 'payees.no_payees'.tr,
                subtitle: 'payees.no_payees_desc'.tr,
                actionLabel: 'payees.add_payee'.tr,
                onAction: () => _showAddPayeeDialog(context),
                iconColor: AppColors.tertiary,
              );
            }

            return RefreshIndicator(
              onRefresh: () async =>
                  context.read<PayeeBloc>().add(const LoadPayees()),
              child: ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                // index 0 = header card, rest = payee cards
                itemCount: payees.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeaderCard(payeeCount: payees.length);
                  }
                  return _buildPayeeCard(context, payees[index - 1]);
                },
              ),
            );
          } else if (state is PayeeError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () => context.read<PayeeBloc>().add(const LoadPayees()),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header card
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard({required int payeeCount}) {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.tertiary, AppColors.tertiaryDark],
      ),
      icon: Icons.people_outline,
      label: 'payees.title'.tr,
      title: '$payeeCount ${'payees.title'.tr.toLowerCase()}',
      subtitle: 'payees.subtitle'.tr,
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payees.what_are'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SectionHeaderBullet('payees.tip_third_party'.tr),
          SectionHeaderBullet('payees.tip_bank'.tr),
          SectionHeaderBullet('payees.tip_reuse'.tr),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Payee card
  // ---------------------------------------------------------------------------

  Widget _buildPayeeCard(BuildContext context, PayeeVO payee) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => _showEditPayeeDialog(context, payee),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
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
                  const SizedBox(height: 2),
                  Text(
                    payee.bankName!,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (payee.accountNumber != null &&
                    payee.accountNumber!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${'payees.account_number'.tr}: ${payee.accountNumber}',
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
                    const Icon(Icons.edit, size: 18),
                    const SizedBox(width: 8),
                    Text('payees.edit'.tr),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(
                      Icons.delete,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'general.delete'.tr,
                      style: const TextStyle(color: AppColors.secondary),
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

  // ---------------------------------------------------------------------------
  // Add dialog
  // ---------------------------------------------------------------------------

  void _showAddPayeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final accountController = TextEditingController();
    final bankController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'payees.add_payee'.tr,
          icon: Icons.person_add_outlined,
          iconColor: AppColors.primary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'payees.name'.tr,
                controller: nameController,
                hint: 'payees.name_hint'.tr,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.account_number'.tr,
                controller: accountController,
                hint: 'payees.account_number_hint'.tr,
                prefixIcon: Icons.numbers,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.bank_name'.tr,
                controller: bankController,
                hint: 'payees.bank_name_hint'.tr,
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.note'.tr,
                controller: noteController,
                hint: 'payees.note_hint'.tr,
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.add'.tr,
              isDefault: true,
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('payees.enter_name'.tr),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
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

  // ---------------------------------------------------------------------------
  // Edit dialog
  // ---------------------------------------------------------------------------

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
          title: 'payees.edit_payee'.tr,
          icon: Icons.edit_note,
          iconColor: AppColors.tertiary,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'payees.name'.tr,
                controller: nameController,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.account_number'.tr,
                controller: accountController,
                prefixIcon: Icons.numbers,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.bank_name'.tr,
                controller: bankController,
                prefixIcon: Icons.account_balance,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'payees.note'.tr,
                controller: noteController,
                prefixIcon: Icons.note_outlined,
                maxLines: 2,
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'payees.update'.tr,
              isDefault: true,
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('payees.enter_name'.tr),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
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

  // ---------------------------------------------------------------------------
  // Delete dialog
  // ---------------------------------------------------------------------------

  void _confirmDeletePayee(BuildContext context, PayeeVO payee) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'payees.delete_payee'.tr,
          message: 'payees.delete_payee_msg'.tr,
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.delete'.tr,
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
