import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/data/db/app_database.dart';
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

/// Enhanced Savings Screen
/// Features:
/// - Grouped savings by type
/// - Progress indicators for goal-based savings
/// - Quick action buttons
/// - Pull-to-refresh
/// - Empty state with CTA
class SavingsScreen extends StatelessWidget {
  const SavingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          SavingsBloc(context.read<ISavingRepository>())
            ..add(LoadSavingsListEvent()),
      child: BlocConsumer<SavingsBloc, SavingsState>(
        listener: (context, state) {
          if (state is SavingsSuccess) {
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
          } else if (state is SavingsError) {
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
          } else {
            return const _SavingsScreenLoading();
          }
        },
      ),
    );
  }

  Widget _buildSavingsList(
    BuildContext context,
    List<ListSavingVO> savingsList,
  ) {
    // Group savings by type
    final Map<SavingTableType, List<ListSavingVO>> savingGroupMap = {
      for (var t in SavingTableType.values) t: [],
    };

    for (final saving in savingsList) {
      final type = SavingTableType.findByValue(saving.saving.type);
      if (type != null) savingGroupMap[type]?.add(saving);
    }

    // If there are no savings, show empty state
    if (savingsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Savings'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
              },
              tooltip: 'Add Savings',
            ),
          ],
        ),
        body: NoSavingsEmptyState(onAdd: () {
          context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
        }),
      );
    }

    // Otherwise, build scrollable list
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
            },
            tooltip: 'Add Savings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<SavingsBloc>().add(LoadSavingsListEvent());
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text('Your Savings', style: AppTextStyles.h1),
              ),
              ...savingGroupMap.entries
                  .where((entry) => entry.value.isNotEmpty)
                  .map((entry) => _buildSavingGroup(context, entry)),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSavingGroup(
    BuildContext context,
    MapEntry<SavingTableType, List<ListSavingVO>> entry,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Text(
              entry.key.label,
              style: AppTextStyles.h3.copyWith(color: AppColors.primary),
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
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
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
                radius: AppIconSize.xl,
                child: const Icon(Icons.savings, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.lg),
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
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'From: ${saving.moneyStorage!.shortName}',
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                constraints: const BoxConstraints(
                  minWidth: AppTouchTarget.min,
                  minHeight: AppTouchTarget.min,
                ),
                onSelected: (String result) async {
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
                        Icon(Icons.edit, size: AppIconSize.sm),
                        SizedBox(width: AppSpacing.sm),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'transaction',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, size: AppIconSize.sm),
                        SizedBox(width: AppSpacing.sm),
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
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AmountText.medium(
                  amount: saving.saving.currentAmount.abs(),
                  type: isMinus ? AmountType.expense : AmountType.neutral,
                ),
              ),
              if (isMinus)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    'Withdrawal',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ),
            ],
          ),
          if (hasGoal) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
    ListSavingVO? saving,
    required List<SvngMoneyStorage> moneyStorageList,
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

    String selectedSavingType =
        saving?.saving.type ?? SavingTableType.saving.value;
    String? selectedMoneyStorageId = saving?.moneyStorage?.id;

    bool isHasGoal = saving?.saving.isHasGoal ?? false;

    List<DropdownMenuItem<String>> moneyStorageItems = [];

    // Default item
    moneyStorageItems.add(
      const DropdownMenuItem<String>(
        value: '',
        child: Text('No Money Storage'),
      ),
    );

    for (var storage in moneyStorageList) {
      moneyStorageItems.add(
        DropdownMenuItem<String>(
          value: storage.id,
          child: Text(storage.shortName),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Saving' : 'Add New Saving')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'Name',
                controller: nameController,
                prefixIcon: Icons.label,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'Initial Amount (RM)',
                controller: initialAmountController,
                prefixText: 'RM',
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
              const SizedBox(height: AppSpacing.lg),
              StatefulBuilder(
                builder: (context, setState) {
                  return AppCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        SwitchListTile(
                          title: const Text('Has Goal?'),
                          value: isHasGoal,
                          onChanged: (value) {
                            setState(() {
                              isHasGoal = value;
                            });
                          },
                        ),
                        if (isHasGoal)
                          AppTextField(
                            label: 'Goal Amount (RM)',
                            controller: goalAmountController,
                            prefixText: 'RM',
                            keyboardType: AppTextFieldKeyboardType.decimal,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a goal amount';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              // Dropdown for saving type
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedSavingType,
                  decoration: const InputDecoration(
                    labelText: 'Saving Type',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: SavingTableType.values.map((type) {
                    return DropdownMenuItem<String>(
                      value: type.value,
                      child: Text(type.label),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedSavingType = newValue;
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Dropdown for money storage
              Container(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: DropdownButtonFormField<String>(
                  initialValue: selectedMoneyStorageId,
                  decoration: const InputDecoration(
                    labelText: 'Money Storage',
                    prefixIcon: Icon(Icons.account_balance),
                  ),
                  items: moneyStorageItems,
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      selectedMoneyStorageId = newValue;
                    }
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'Cancel',
                      onPressed: () {
                        context.read<SavingsBloc>().add(LoadSavingsListEvent());
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'Update' : 'Add',
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          final initialAmount = double.parse(
                            initialAmountController.text,
                          );
                          final goalAmount =
                              isHasGoal && goalAmountController.text.isNotEmpty
                              ? double.parse(goalAmountController.text)
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
                  context.read<SavingsBloc>().add(LoadSavingsListEvent());
                },
              ),
            ),
          ],
        ),
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
  final VoidCallback? onAdd;

  const NoSavingsEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.savings_outlined,
      title: 'No savings yet',
      subtitle: 'Add your first savings account to get started',
      actionLabel: 'Add Savings',
      onAction: onAdd ??
          () {
            context.read<SavingsBloc>().add(LoadAddSavingsFormEvent());
          },
      iconColor: AppColors.success,
    );
  }
}
