import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/data/repositories/saving/impl/money_storage_repository.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_event.dart';
import 'package:wise_spends/presentation/blocs/money_storage/money_storage_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';

/// Enhanced Money Storage Screen
/// Features:
/// - Card-based layout with gradient backgrounds
/// - Quick overview of all money storage accounts
/// - Total balance summary
/// - Pull-to-refresh
/// - Empty state with CTA
class MoneyStorageScreen extends StatelessWidget {
  const MoneyStorageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          MoneyStorageBloc(MoneyStorageRepository())
            ..add(LoadMoneyStorageListEvent()),
      child: BlocConsumer<MoneyStorageBloc, MoneyStorageState>(
        listener: (context, state) {
          if (state is MoneyStorageSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          } else if (state is MoneyStorageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
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
          Map<ActionButtonEnum, VoidCallback?> floatingActionButtonMap = {};
          if (state is MoneyStorageListLoaded) {
            floatingActionButtonMap[ActionButtonEnum.addMoneyStorage] = () =>
                context.read<MoneyStorageBloc>().add(
                  LoadAddMoneyStorageEvent(),
                );
          }

          BlocProvider.of<ActionButtonBloc>(context).add(
            OnUpdateActionButtonEvent(
              context: context,
              actionButtonMap: floatingActionButtonMap,
            ),
          );

          if (state is MoneyStorageLoading) {
            return const _MoneyStorageScreenLoading();
          } else if (state is MoneyStorageListLoaded) {
            return _buildMoneyStorageList(context, state.moneyStorageList);
          } else if (state is MoneyStorageFormLoaded) {
            return _buildMoneyStorageForm(
              context,
              isEditing: state.isEditing,
              moneyStorage: state.moneyStorage,
            );
          } else if (state is MoneyStorageError) {
            return _buildErrorState(context, state.message);
          } else {
            return const _MoneyStorageScreenLoading();
          }
        },
      ),
    );
  }

  Widget _buildMoneyStorageList(
    BuildContext context,
    List<MoneyStorageVO> moneyStorageList,
  ) {
    // Calculate total balance
    final totalBalance = moneyStorageList.fold<double>(
      0.0,
      (sum, storage) => sum + storage.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Storage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<MoneyStorageBloc>().add(
                LoadAddMoneyStorageEvent(),
              );
            },
            tooltip: 'Add Money Storage',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<MoneyStorageBloc>().add(LoadMoneyStorageListEvent());
        },
        child: moneyStorageList.isNotEmpty
            ? SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Balance Card
                    _buildTotalBalanceCard(context, totalBalance),
                    const SizedBox(height: AppSpacing.xxl),

                    // Section Header
                    SectionHeader(
                      title: 'Your Accounts',
                      subtitle:
                          '${moneyStorageList.length} ${moneyStorageList.length == 1 ? 'account' : 'accounts'}',
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Money Storage Cards
                    ...moneyStorageList.map(
                      (storage) => _buildMoneyStorageCard(context, storage),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              )
            : NoMoneyStorageEmptyState(onAdd: () {
                context.read<MoneyStorageBloc>().add(
                  LoadAddMoneyStorageEvent(),
                );
              }),
      ),
    );
  }

  Widget _buildTotalBalanceCard(BuildContext context, double totalBalance) {
    return AppCard.gradient(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      borderRadius: BorderRadius.circular(AppRadius.lg),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.account_balance,
                color: Colors.white70,
                size: AppIconSize.lg,
              ),
              SizedBox(width: AppSpacing.sm),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 2,
            ).format(totalBalance),
            style: AppTextStyles.balanceDisplay,
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStorageCard(BuildContext context, MoneyStorageVO storage) {
    final isMinus = storage.amount < 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      onTap: () => context.read<MoneyStorageBloc>().add(
        LoadEditMoneyStorageEvent(storage.moneyStorage.id),
      ),
      child: Row(
        children: [
          Container(
            width: AppTouchTarget.min,
            height: AppTouchTarget.min,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: AppIconSize.lg,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storage.moneyStorage.shortName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  storage.moneyStorage.longName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormat.currency(
                  symbol: 'RM ',
                  decimalDigits: 2,
                ).format(storage.amount.abs()),
                style: AppTextStyles.amountSmall.copyWith(
                  color: isMinus ? AppColors.secondary : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isMinus)
                Container(
                  margin: const EdgeInsets.only(top: AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Negative',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
            constraints: const BoxConstraints(
              minWidth: AppTouchTarget.min,
              minHeight: AppTouchTarget.min,
            ),
            onSelected: (String result) {
              if (result == 'edit') {
                context.read<MoneyStorageBloc>().add(
                  LoadEditMoneyStorageEvent(storage.moneyStorage.id),
                );
              }
              if (result == 'delete') {
                showDeleteDialog(
                  context: context,
                  onDelete: () {
                    context.read<MoneyStorageBloc>().add(
                      DeleteMoneyStorageEvent(storage.moneyStorage.id),
                    );
                  },
                );
              }
            },
            itemBuilder: (BuildContext context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: AppIconSize.sm),
                    SizedBox(width: AppSpacing.sm),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete,
                      size: AppIconSize.sm,
                      color: AppColors.secondary,
                    ),
                    SizedBox(width: AppSpacing.sm),
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

  Widget _buildMoneyStorageForm(
    BuildContext context, {
    required bool isEditing,
    MoneyStorageVO? moneyStorage,
  }) {
    final formKey = GlobalKey<FormState>();
    final shortNameController = TextEditingController(
      text: moneyStorage?.moneyStorage.shortName ?? '',
    );
    final longNameController = TextEditingController(
      text: moneyStorage?.moneyStorage.longName ?? '',
    );
    final amountController = TextEditingController(
      text: moneyStorage != null
          ? moneyStorage.amount.toStringAsFixed(2)
          : '',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Money Storage' : 'Add New Money Storage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'Short Name',
                controller: shortNameController,
                prefixIcon: Icons.label,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a short name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Full Name',
                controller: longNameController,
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Amount (RM)',
                controller: amountController,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.decimal,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      onPressed: () {
                        context.read<MoneyStorageBloc>().add(
                          LoadMoneyStorageListEvent(),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'Update' : 'Add',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final amount = double.parse(amountController.text);
                          if (isEditing && moneyStorage != null) {
                            context.read<MoneyStorageBloc>().add(
                              UpdateMoneyStorageEvent(
                                id: moneyStorage.moneyStorage.id,
                                shortName: shortNameController.text,
                                longName: longNameController.text,
                                amount: amount,
                              ),
                            );
                          } else {
                            // Add new account - allows multiple accounts
                            context.read<MoneyStorageBloc>().add(
                              AddMoneyStorageEvent(
                                shortName: shortNameController.text,
                                longName: longNameController.text,
                                amount: amount,
                              ),
                            );
                            // Show success and return to list
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle,
                                        color: Colors.white),
                                    const SizedBox(width: AppSpacing.sm),
                                    const Text(
                                      'Money storage added successfully',
                                    ),
                                  ],
                                ),
                                backgroundColor: AppColors.success,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.md),
                                ),
                              ),
                            );
                            Navigator.pop(context);
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money Storage')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppIconSize.hero,
              color: AppColors.secondary,
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Oops! Something went wrong', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Retry',
                onPressed: () {
                  context.read<MoneyStorageBloc>().add(
                    LoadMoneyStorageListEvent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyStorageScreenLoading extends StatelessWidget {
  const _MoneyStorageScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money Storage')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class NoMoneyStorageEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;

  const NoMoneyStorageEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.account_balance_outlined,
      title: 'No money storage yet',
      subtitle: 'Add your first money storage to get started',
      actionLabel: 'Add Money Storage',
      onAction: onAdd ??
          () {
            context.read<MoneyStorageBloc>().add(
              LoadAddMoneyStorageEvent(),
            );
          },
      iconColor: AppColors.tertiary,
    );
  }
}
