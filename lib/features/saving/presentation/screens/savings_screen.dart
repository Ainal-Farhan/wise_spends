import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/core/constants/constant/enum/action_button_enum.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/features/category/data/repositories/i_category_repository.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_bloc.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_event.dart';
import 'package:wise_spends/features/saving/presentation/bloc/savings_state.dart';
import 'package:wise_spends/presentation/widgets/navigation/navigation_sidebar.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/forms/form_category_selector.dart';
import 'package:wise_spends/shared/components/reservation_info_widget.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/presentation/widgets/savings_reserve_info_card.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

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
              backgroundColor: Theme.of(context).colorScheme.primary,
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
        context.read<ActionButtonBloc>().add(
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
        drawer: NavigationSidebar(),
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
      drawer: NavigationSidebar(),
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
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primary,
          Theme.of(context).colorScheme.primary,
        ],
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
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.folder_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
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
    final hasCategory = saving.saving.categoryId != null;

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
                backgroundColor: Theme.of(context).colorScheme.primary,
                radius: 24,
                child: Icon(
                  hasCategory && saving.category != null
                      ? CategoryIconMapper.getIconForCategory(
                          saving.category!.iconCodePoint,
                        )
                      : Icons.wallet,
                  color: Colors.white,
                ),
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
                    if (hasCategory) ...[
                      const SizedBox(height: 4),
                      Text(
                        'savings.default_category'.tr,
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
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
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'general.delete'.tr,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
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

          // Display reservation info if there are reservations
          if (saving.hasReservations) ...[
            const SizedBox(height: AppSpacing.md),
            SavingsReserveInfoCard(
              reserveSummary: saving.reserveSummary!,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  showDragHandle: false,
                  backgroundColor: Colors.transparent,
                  builder: (_) => ReservationDetailsSheet(
                    reserveSummary: saving.reserveSummary!,
                    savingName: saving.saving.name,
                  ),
                );
              },
            ),
          ],

          if (hasGoal) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
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
      text: saving != null
          ? saving.saving.currentAmount.toStringAsFixed(2)
          : '',
    );
    final goalAmountController = TextEditingController(
      text: saving != null ? saving.saving.goal.toStringAsFixed(2) : '',
    );
    bool isHasGoal = saving?.saving.isHasGoal ?? false;
    String selectedSavingType =
        saving?.saving.type ?? SavingTableType.values.first.value;
    String? selectedMoneyStorageId = saving?.moneyStorage?.id;
    String? selectedCategoryId = saving?.saving.categoryId;

    final moneyStorageItems = <DropdownMenuItem<String>>[
      DropdownMenuItem(value: '', child: Text('savings.no_money_storage'.tr)),
      ...moneyStorageList.map(
        (s) => DropdownMenuItem(value: s.id, child: Text(s.shortName)),
      ),
    ];

    return BlocProvider(
      create: (ctx) =>
          CategoryBloc(ctx.read<ICategoryRepository>())
            ..add(LoadCategoriesEvent()),
      child: _SavingsFormContent(
        formKey: formKey,
        nameController: nameController,
        initialAmountController: initialAmountController,
        goalAmountController: goalAmountController,
        isHasGoal: isHasGoal,
        selectedSavingType: selectedSavingType,
        selectedMoneyStorageId: selectedMoneyStorageId,
        selectedCategoryId: selectedCategoryId,
        moneyStorageItems: moneyStorageItems,
        isEditing: isEditing,
        saving: saving,
      ),
    );
  }

  Widget _buildTransactionForm(BuildContext context, String savingId) {
    return Scaffold(
      appBar: AppBar(title: Text('savings.saving_transactions'.tr)),
      drawer: NavigationSidebar(),
      body: Center(child: Text('savings.transaction_form_coming_soon'.tr)),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Scaffold(
      appBar: AppBar(title: Text('savings.title'.tr)),
      drawer: NavigationSidebar(),
      body: ErrorStateWidget(
        message: message,
        onAction: () => context.read<SavingsBloc>().add(LoadSavingsListEvent()),
      ),
    );
  }
}

class _SavingsFormContent extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController initialAmountController;
  final TextEditingController goalAmountController;
  final bool isHasGoal;
  final String selectedSavingType;
  final String? selectedMoneyStorageId;
  final String? selectedCategoryId;
  final List<DropdownMenuItem<String>> moneyStorageItems;
  final bool isEditing;
  final dynamic saving;

  const _SavingsFormContent({
    required this.formKey,
    required this.nameController,
    required this.initialAmountController,
    required this.goalAmountController,
    required this.isHasGoal,
    required this.selectedSavingType,
    required this.selectedMoneyStorageId,
    required this.selectedCategoryId,
    required this.moneyStorageItems,
    required this.isEditing,
    required this.saving,
  });

  @override
  State<_SavingsFormContent> createState() => _SavingsFormContentState();
}

class _SavingsFormContentState extends State<_SavingsFormContent> {
  String? _selectedCategoryId;
  bool _isHasGoal = false;
  String _selectedSavingType = '';
  String? _selectedMoneyStorageId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _isHasGoal = widget.isHasGoal;
    _selectedSavingType = widget.selectedSavingType;
    _selectedMoneyStorageId = widget.selectedMoneyStorageId;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final categories = categoryState is CategoryLoaded
            ? categoryState.categories
            : <CategoryEntity>[];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.isEditing
                  ? 'general.edit_saving'.tr
                  : 'general.add_new_saving'.tr,
            ),
            actions: [
              if (!widget.isEditing)
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    Navigator.pop(context);
                    context.read<CategoryBloc>().add(
                      const LoadCategoriesForTransactionTypeEvent(
                        TransactionType.expense,
                      ),
                    );
                  },
                  tooltip: 'categories.add'.tr,
                ),
            ],
          ),
          drawer: NavigationSidebar(),
          body: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: widget.formKey,
              child: ListView(
                children: [
                  AppTextField(
                    label: 'general.name'.tr,
                    controller: widget.nameController,
                    prefixIcon: Icons.label,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'general.initial_amount'.tr,
                    controller: widget.initialAmountController,
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
                            value: _isHasGoal,
                            onChanged: (v) => setState(() => _isHasGoal = v),
                          ),
                          if (_isHasGoal) ...[
                            const SizedBox(height: 8),
                            AppTextField(
                              label: 'general.goal_amount'.tr,
                              controller: widget.goalAmountController,
                              prefixText: 'RM ',
                              keyboardType: AppTextFieldKeyboardType.decimal,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FormCategorySelector(
                    selectedCategory:
                        _selectedCategoryId != null && categories.isNotEmpty
                        ? categories.firstWhere(
                            (c) => c.id == _selectedCategoryId,
                            orElse: () => categories.first,
                          )
                        : null,
                    categories: categories,
                    label: 'savings.default_category'.tr,
                    hint: 'savings.select_default_category'.tr,
                    onCategorySelected: (category) {
                      setState(() {
                        _selectedCategoryId = category?.id;
                      });
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedSavingType,
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
                    onChanged: (v) =>
                        setState(() => _selectedSavingType = v ?? 'saving'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedMoneyStorageId,
                    decoration: InputDecoration(
                      labelText: 'general.money_storage'.tr,
                      prefixIcon: const Icon(Icons.account_balance),
                    ),
                    items: widget.moneyStorageItems,
                    onChanged: (v) =>
                        setState(() => _selectedMoneyStorageId = v),
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
                          label: widget.isEditing
                              ? 'general.update'.tr
                              : 'general.add'.tr,
                          onPressed: () {
                            if (widget.formKey.currentState!.validate()) {
                              final initialAmount =
                                  double.tryParse(
                                    widget.initialAmountController.text,
                                  ) ??
                                  0.0;
                              final goalAmount =
                                  _isHasGoal &&
                                      widget
                                          .goalAmountController
                                          .text
                                          .isNotEmpty
                                  ? double.tryParse(
                                          widget.goalAmountController.text,
                                        ) ??
                                        0.0
                                  : 0.0;
                              if (widget.isEditing && widget.saving != null) {
                                context.read<SavingsBloc>().add(
                                  UpdateSavingsEvent(
                                    id: widget.saving.saving.id,
                                    name: widget.nameController.text,
                                    initialAmount: initialAmount,
                                    isHasGoal: _isHasGoal,
                                    goalAmount: goalAmount,
                                    moneyStorageId:
                                        _selectedMoneyStorageId ?? '',
                                    savingType: _selectedSavingType,
                                    categoryId: _selectedCategoryId,
                                  ),
                                );
                              } else {
                                context.read<SavingsBloc>().add(
                                  AddSavingsEvent(
                                    name: widget.nameController.text,
                                    initialAmount: initialAmount,
                                    isHasGoal: _isHasGoal,
                                    goalAmount: goalAmount,
                                    moneyStorageId:
                                        _selectedMoneyStorageId ?? '',
                                    savingType: _selectedSavingType,
                                    categoryId: _selectedCategoryId,
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
      },
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
      drawer: NavigationSidebar(),
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
      iconColor: Theme.of(context).colorScheme.primary,
    );
  }
}
