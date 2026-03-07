import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
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
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
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
    final Map<String, List<ListSavingVO>> savingGroupMap = {};
    for (final saving in savingsList) {
      final type = saving.saving.type;
      savingGroupMap.putIfAbsent(type, () => []).add(saving);
    }

    // Total balance & stats
    final totalBalance = savingsList.fold<double>(
      0.0,
      (sum, s) => sum + s.saving.currentAmount,
    );
    final withGoal = savingsList.where((s) => s.saving.isHasGoal).length;
    final accountCount = savingsList.length;

    if (savingsList.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('savings.title'.tr)),
        body: const NoSavingsEmptyState(),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('savings.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () =>
                context.read<SavingsBloc>().add(LoadAddSavingsFormEvent()),
            tooltip: 'general.add_new_saving'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<SavingsBloc>().add(LoadSavingsListEvent()),
        child: ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          // index 0 = card header, rest = groups
          itemCount: savingGroupMap.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildHeaderCard(
                context,
                totalBalance: totalBalance,
                accountCount: accountCount,
                withGoal: withGoal,
              );
            }
            final entry = savingGroupMap.entries.elementAt(index - 1);
            return _buildSavingGroup(context, entry);
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header card — SectionHeader.card with stats row inside collapsible
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard(
    BuildContext context, {
    required double totalBalance,
    required int accountCount,
    required int withGoal,
  }) {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      icon: Icons.savings_outlined,
      label: 'general.your_savings'.tr,
      title: NumberFormat.currency(
        symbol: 'RM ',
        decimalDigits: 2,
      ).format(totalBalance),
      subtitle:
          '$accountCount ${'general.accounts'.tr}  ·  '
          '${'savings.with_goal'.trWith({'total': withGoal.toString()})}',
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'general.your_savings'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          SectionHeaderBullet('savings.what_are_desc'.tr),
          SectionHeaderBullet('savings.tip_goal'.tr),
          SectionHeaderBullet('savings.tip_storage'.tr),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Group header using plain SectionHeader
  // ---------------------------------------------------------------------------

  Widget _buildSavingGroup(
    BuildContext context,
    MapEntry<String, List<ListSavingVO>> entry,
  ) {
    final label = SavingTableType.findByValue(entry.key)?.label ?? entry.key;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: label,
            leading: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_outlined,
                size: 16,
                color: AppColors.primary,
              ),
            ),
            subtitle:
                '${entry.value.length} '
                '${entry.value.length == 1 ? 'account' : 'accounts'}',
          ),
          const SizedBox(height: AppSpacing.md),
          ...entry.value.map((s) => _buildSavingCard(context, s)),
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
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
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
              const SizedBox(width: AppSpacing.md),
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
                    case 'transaction':
                      context.read<SavingsBloc>().add(
                        LoadSavingTransactionEvent(savingId: saving.saving.id),
                      );
                    case 'delete':
                      showDeleteDialog(
                        context: context,
                        autoDisplayMessage: false,
                        onDelete: () async => context.read<SavingsBloc>().add(
                          DeleteSavingEvent(saving.saving.id),
                        ),
                      );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text('savings.edit'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'transaction',
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 18),
                        const SizedBox(width: 8),
                        Text('savings.transactions'.tr),
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
                AppBadge(
                  label: 'Withdrawal',
                  status: AppBadgeStatus.error,
                  variant: AppBadgeVariant.soft,
                ),
            ],
          ),
          if (hasGoal) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
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

    final moneyStorageItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: '', child: Text('savings.no_money_storage'.tr)),
      ...moneyStorageList.map(
        (s) => DropdownMenuItem(value: s.id, child: Text(s.shortName)),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing ? 'general.edit_saving'.tr : 'general.add_new_saving'.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'general.name'.tr,
                controller: nameController,
                prefixIcon: Icons.label,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'general.initial_amount'.tr,
                controller: initialAmountController,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.decimal,
              ),
              const SizedBox(height: AppSpacing.md),
              StatefulBuilder(
                builder: (context, setState) => AppCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('savings.has_goal'.tr),
                        value: isHasGoal,
                        onChanged: (v) => setState(() => isHasGoal = v),
                      ),
                      if (isHasGoal) ...[
                        const SizedBox(height: 8),
                        AppTextField(
                          label: 'general.goal_amount'.tr,
                          controller: goalAmountController,
                          prefixText: 'RM ',
                          keyboardType: AppTextFieldKeyboardType.decimal,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedSavingType,
                decoration: InputDecoration(
                  labelText: 'general.saving_type'.tr,
                  prefixIcon: const Icon(Icons.category),
                ),
                items: SavingTableType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t.value,
                        child: Text(t.label),
                      ),
                    )
                    .toList(),
                onChanged: (v) => selectedSavingType = v ?? 'saving',
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedMoneyStorageId,
                decoration: InputDecoration(
                  labelText: 'general.money_storage'.tr,
                  prefixIcon: const Icon(Icons.account_balance),
                ),
                items: moneyStorageItems,
                onChanged: (v) => selectedMoneyStorageId = v,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'general.cancel'.tr,
                      onPressed: () => context.read<SavingsBloc>().add(
                        LoadSavingsListEvent(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'general.update'.tr : 'general.add'.tr,
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
      appBar: AppBar(title: Text('savings.saving_transactions'.tr)),
      body: Center(child: Text('savings.transaction_form_coming_soon'.tr)),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: Text('savings.title'.tr)),
      body: ErrorStateWidget(
        message: message,
        onAction: () => context.read<SavingsBloc>().add(LoadSavingsListEvent()),
      ),
    );
  }
}

// =============================================================================
// Loading skeleton
// =============================================================================

class _SavingsScreenLoading extends StatelessWidget {
  const _SavingsScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('savings.title'.tr)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}

// =============================================================================
// Empty state
// =============================================================================

class NoSavingsEmptyState extends StatelessWidget {
  const NoSavingsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.savings_outlined,
      title: 'No savings yet',
      subtitle: 'Add your first savings account to get started',
      actionLabel: 'general.add_new_saving'.tr,
      onAction: () =>
          context.read<SavingsBloc>().add(LoadAddSavingsFormEvent()),
      iconColor: AppColors.success,
    );
  }
}
