import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/alert_dialog/delete_dialog.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

/// Enhanced Savings Screen - Pure BLoC
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SavingsBloc(context.read<ISavingRepository>())
            ..add(LoadSavingsListEvent()),
      child: const _SavingsScreenContent(),
    );
  }
}

class _SavingsScreenContent extends StatelessWidget {
  const _SavingsScreenContent();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SavingsBloc, SavingsState>(
      listener: (context, state) {
        if (state is SavingsSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state is SavingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        // Update action button
        Map<ActionButtonEnum, VoidCallback?> floatingActionButtonMap = {};
        if (!(state is SavingsFormLoaded ||
            state is SavingTransactionFormLoaded)) {
          floatingActionButtonMap[ActionButtonEnum.addNewSaving] = () {
            context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
          };
        }
        BlocProvider.of<ActionButtonBloc>(context).add(
          OnUpdateActionButtonEvent(
            context: context,
            actionButtonMap: floatingActionButtonMap,
          ),
        );

        if (state is SavingsLoading) {
          return const _SavingsScreenLoading();
        } else if (state is SavingsListLoaded) {
          return _buildSavingsList(context, state.savingsList);
        } else if (state is SavingsFormLoaded) {
          return _buildSavingsForm(
            context,
            isEditing: state.isEditing,
            saving: state.saving,
            moneyStorageList: state.moneyStorageOptions,
          );
        } else if (state is SavingTransactionFormLoaded) {
          return _buildTransactionForm(context, state.savingId);
        } else if (state is SavingsError) {
          return _buildErrorState(context, state.message);
        }
        return const _SavingsScreenLoading();
      },
    );
  }

  Widget _buildSavingsList(
    BuildContext context,
    List<ListSavingVO> savingsList,
  ) {
    // Group savings by type
    final Map<String, List<ListSavingVO>> savingGroupMap = {};

    for (final saving in savingsList) {
      final type = saving.saving.type;
      if (!savingGroupMap.containsKey(type)) {
        savingGroupMap[type] = [];
      }
      savingGroupMap[type]!.add(saving);
    }

    if (savingsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Savings')),
        body: const NoSavingsEmptyState(),
      );
    }

    // Calculate total balance
    final totalBalance = savingsList.fold<double>(
      0.0,
      (sum, saving) => sum + saving.saving.currentAmount,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
            },
            tooltip: 'Add Money Storage',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SavingsBloc>().add(LoadSavingsListEvent());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Card
              _buildTotalBalanceCard(context, totalBalance),
              const SizedBox(height: 24),

              // Section Header
              SectionHeader(
                title: 'Your Savings',
                subtitle:
                    '${savingsList.length} ${savingsList.length == 1 ? 'account' : 'accounts'}',
              ),
              const SizedBox(height: 12),

              // Savings Cards
              ...savingGroupMap.entries.map(
                (entry) => _buildSavingGroup(context, entry),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
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

  Widget _buildSavingGroup(
    BuildContext context,
    MapEntry<String, List<ListSavingVO>> entry,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Text(
              SavingTableType.findByValue(entry.key)!.label.toUpperCase(),
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
          ...entry.value.map((saving) => _buildSavingCard(context, saving)),
        ],
      ),
    );
  }

  Widget _buildSavingCard(BuildContext context, ListSavingVO saving) {
    final isMinus = saving.saving.currentAmount < 0;
    final hasGoal = saving.saving.isHasGoal && saving.saving.goal > 0;
    final progress = hasGoal
        ? (saving.saving.currentAmount / saving.saving.goal).clamp(0.0, 1.0)
        : 0.0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => context.read<SavingsBloc>().add(
        LoadEditSavingsEvent(saving.saving.id),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 24,
                child: const Icon(Icons.savings, color: Colors.white),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      saving.saving.name ?? 'Unnamed Saving',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (saving.moneyStorage != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'From: ${saving.moneyStorage!.shortName}',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (result) {
                  switch (result) {
                    case 'edit':
                      context.read<SavingsBloc>().add(
                        LoadEditSavingsEvent(saving.saving.id),
                      );
                      break;
                    case 'transaction':
                      context.read<SavingsBloc>().add(
                        LoadSavingTransactionEvent(savingId: saving.saving.id),
                      );
                      break;
                    case 'delete':
                      showDeleteDialog(
                        context: context,
                        autoDisplayMessage: false,
                        onDelete: () async {
                          context.read<SavingsBloc>().add(
                            DeleteSavingEvent(saving.saving.id),
                          );
                        },
                      );
                      break;
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'transaction',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, size: 18),
                        SizedBox(width: 8),
                        Text('Transactions'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: AppColors.secondary,
                        ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AmountText.medium(
                  amount: saving.saving.currentAmount.abs(),
                  type: isMinus ? AmountType.expense : AmountType.neutral,
                ),
              ),
              if (isMinus)
                AppBadge(
                  label: 'Withdrawal',
                  status: AppBadgeStatus.error,
                  variant: AppBadgeVariant.soft,
                ),
            ],
          ),
          if (hasGoal) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toInt()}% of goal',
                  style: AppTextStyles.caption,
                ),
                Text(
                  'Goal: ${NumberFormat.currency(symbol: 'RM', decimalDigits: 2).format(saving.saving.goal)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSavingsForm(
    BuildContext context, {
    required bool isEditing,
    dynamic saving,
    required List<dynamic> moneyStorageList,
  }) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(
      text: saving?.saving.name ?? '',
    );
    final initialAmountController = TextEditingController(
      text: saving?.saving.currentAmount.toString() ?? '',
    );
    final goalAmountController = TextEditingController(
      text: saving?.saving.goal.toString() ?? '',
    );
    bool isHasGoal = saving?.saving.isHasGoal ?? false;
    String selectedSavingType =
        saving?.saving.type ?? SavingTableType.values.first.value;
    String? selectedMoneyStorageId = saving?.moneyStorage?.id;

    List<DropdownMenuItem<String>> moneyStorageItems = [
      const DropdownMenuItem(value: '', child: Text('No Money Storage')),
      ...moneyStorageList.map(
        (storage) =>
            DropdownMenuItem(value: storage.id, child: Text(storage.shortName)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Saving' : 'Add New Saving')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'Name',
                controller: nameController,
                prefixIcon: Icons.label,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Initial Amount (RM)',
                controller: initialAmountController,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.decimal,
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Has Goal?'),
                        value: isHasGoal,
                        onChanged: (value) => setState(() => isHasGoal = value),
                      ),
                      if (isHasGoal) ...[
                        const SizedBox(height: 8),
                        AppTextField(
                          label: 'Goal Amount (RM)',
                          controller: goalAmountController,
                          prefixText: 'RM ',
                          keyboardType: AppTextFieldKeyboardType.decimal,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedSavingType,
                decoration: const InputDecoration(
                  labelText: 'Saving Type',
                  prefixIcon: Icon(Icons.category),
                ),
                items: SavingTableType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type.value,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => selectedSavingType = value ?? 'saving',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedMoneyStorageId,
                decoration: const InputDecoration(
                  labelText: 'Money Storage',
                  prefixIcon: Icon(Icons.account_balance),
                ),
                items: moneyStorageItems,
                onChanged: (value) => selectedMoneyStorageId = value,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      onPressed: () => context.read<SavingsBloc>().add(
                        LoadSavingsListEvent(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'Update' : 'Add',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final initialAmount =
                              double.tryParse(initialAmountController.text) ??
                              0.0;
                          final goalAmount =
                              isHasGoal && goalAmountController.text.isNotEmpty
                              ? double.tryParse(goalAmountController.text) ??
                                    0.0
                              : 0.0;

                          if (isEditing && saving != null) {
                            context.read<SavingsBloc>().add(
                              UpdateSavingsEvent(
                                id: saving.saving.id,
                                name: nameController.text,
                                initialAmount: initialAmount,
                                isHasGoal: isHasGoal,
                                goalAmount: goalAmount,
                                moneyStorageId: selectedMoneyStorageId ?? '',
                                savingType: selectedSavingType,
                              ),
                            );
                          } else {
                            context.read<SavingsBloc>().add(
                              AddSavingsEvent(
                                name: nameController.text,
                                initialAmount: initialAmount,
                                isHasGoal: isHasGoal,
                                goalAmount: goalAmount,
                                moneyStorageId: selectedMoneyStorageId ?? '',
                                savingType: selectedSavingType,
                              ),
                            );
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

  Widget _buildTransactionForm(BuildContext context, String savingId) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saving Transactions')),
      body: const Center(child: Text('Transaction form coming soon')),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: ErrorStateWidget(
        message: message,
        onAction: () => context.read<SavingsBloc>().add(LoadSavingsListEvent()),
      ),
    );
  }
}

class _SavingsScreenLoading extends StatelessWidget {
  const _SavingsScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Savings')),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

class NoSavingsEmptyState extends StatelessWidget {
  const NoSavingsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.savings_outlined,
      title: 'No savings yet',
      subtitle: 'Add your first savings account to get started',
      actionLabel: 'Add Savings',
      onAction: () {
        context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
      },
      iconColor: AppColors.success,
    );
  }
}
