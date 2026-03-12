import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/features/saving/data/repositories/impl/money_storage_repository.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/money_storage_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/money_storage_event.dart';
import 'package:wise_spends/features/saving/presentation/bloc/money_storage_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/features/saving/domain/entities/money_storage_vo.dart';

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
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
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
          Map<ActionButtonEnum, VoidCallback?> floatingActionButtonMap = {};
          if (state is MoneyStorageListLoaded) {
            floatingActionButtonMap[ActionButtonEnum.addMoneyStorage] = () =>
                context.read<MoneyStorageBloc>().add(
                  LoadAddMoneyStorageEvent(),
                );
          }
          context.read<ActionButtonBloc>().add(
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
          }
          return const _MoneyStorageScreenLoading();
        },
      ),
    );
  }

  Widget _buildMoneyStorageList(
    BuildContext context,
    List<MoneyStorageVO> list,
  ) {
    final totalBalance = list.fold<double>(0.0, (s, m) => s + m.amount);
    final negativeCount = list.where((m) => m.amount < 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('money_storage.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.read<MoneyStorageBloc>().add(
              LoadAddMoneyStorageEvent(),
            ),
            tooltip: 'general.add_money_storage'.tr,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async =>
            context.read<MoneyStorageBloc>().add(LoadMoneyStorageListEvent()),
        child: list.isNotEmpty
            ? ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: list.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return _buildHeaderCard(
                      context,
                      totalBalance: totalBalance,
                      accountCount: list.length,
                      negativeCount: negativeCount,
                    );
                  }
                  return _buildMoneyStorageCard(context, list[index - 1]);
                },
              )
            : NoMoneyStorageEmptyState(
                onAdd: () => context.read<MoneyStorageBloc>().add(
                  LoadAddMoneyStorageEvent(),
                ),
              ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header card — SectionHeader.card
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard(
    BuildContext context, {
    required double totalBalance,
    required int accountCount,
    required int negativeCount,
  }) {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primary, AppColors.primaryDark],
      ),
      icon: Icons.account_balance,
      label: 'general.your_accounts'.tr,
      title: NumberFormat.currency(
        symbol: 'RM ',
        decimalDigits: 2,
      ).format(totalBalance),
      subtitle:
          '$accountCount ${'general.accounts'.tr}'
          '${negativeCount > 0 ? '  ·  $negativeCount negative' : ''}',
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeaderBullet('money_storage.tip_short_name'.tr),
          SectionHeaderBullet('money_storage.tip_track'.tr),
          SectionHeaderBullet('money_storage.tip_negative'.tr),
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
            decoration: const BoxDecoration(
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
            onSelected: (result) async {
              if (result == 'edit') {
                context.read<MoneyStorageBloc>().add(
                  LoadEditMoneyStorageEvent(storage.moneyStorage.id),
                );
              } else if (result == 'delete') {
                final confirmed = await showDeleteDialog(
                  context: context,
                  title: 'Delete Money Storage',
                  message:
                      'Are you sure you want to delete this money storage?',
                );
                if (confirmed == true) {
                  context.read<MoneyStorageBloc>().add(
                    DeleteMoneyStorageEvent(storage.moneyStorage.id),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: AppIconSize.sm),
                    SizedBox(width: AppSpacing.sm),
                    Text('money_storage.edit'.tr),
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'general.update_money_storage'.tr
              : 'general.add_money_storage'.tr,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              AppTextField(
                label: 'general.short_name'.tr,
                controller: shortNameController,
                prefixIcon: Icons.label,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error.validation.required'.tr
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: 'general.full_name'.tr,
                controller: longNameController,
                prefixIcon: Icons.title,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error.validation.required'.tr
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.tertiary.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.info_outline,
                            color: AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Amount',
                                style: AppTextStyles.bodySemiBold,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total will be calculated automatically.',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xxxl),
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'general.cancel'.tr,
                      onPressed: () => context.read<MoneyStorageBloc>().add(
                        LoadMoneyStorageListEvent(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: isEditing ? 'general.update'.tr : 'general.add'.tr,
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          if (isEditing && moneyStorage != null) {
                            context.read<MoneyStorageBloc>().add(
                              UpdateMoneyStorageEvent(
                                id: moneyStorage.moneyStorage.id,
                                shortName: shortNameController.text,
                                longName: longNameController.text,
                              ),
                            );
                          } else {
                            context.read<MoneyStorageBloc>().add(
                              AddMoneyStorageEvent(
                                shortName: shortNameController.text,
                                longName: longNameController.text,
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

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: Text('money_storage.title'.tr)),
      body: ErrorStateWidget(
        message: message,
        onAction: () =>
            context.read<MoneyStorageBloc>().add(LoadMoneyStorageListEvent()),
      ),
    );
  }
}

// =============================================================================

class _MoneyStorageScreenLoading extends StatelessWidget {
  const _MoneyStorageScreenLoading();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('money_storage.title'.tr)),
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
      actionLabel: 'general.add_money_storage'.tr,
      onAction:
          onAdd ??
          () =>
              context.read<MoneyStorageBloc>().add(LoadAddMoneyStorageEvent()),
      iconColor: AppColors.tertiary,
    );
  }
}
