import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/data/repositories/category/i_category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_bloc.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_event.dart';
import 'package:wise_spends/presentation/blocs/savings/savings_state.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/presentation/blocs/transaction_form/transaction_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction_form/transaction_form_event.dart';
import 'package:wise_spends/presentation/blocs/transaction_form/transaction_form_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

class AddTransactionScreenArgs {
  final TransactionType? preselectedType;
  final String? editingTransactionId;
  final TransactionEntity? existingTransaction;
  final CategoryEntity? existingCategory;
  final TimeOfDay? existingTime;

  const AddTransactionScreenArgs({
    this.preselectedType,
    this.editingTransactionId,
    this.existingTransaction,
    this.existingCategory,
    this.existingTime,
  });
}

/// Provider wrapper — sets up all BLoCs then hands off to the stateful content.
class AddTransactionScreen extends StatelessWidget {
  final AddTransactionScreenArgs? args;

  const AddTransactionScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) =>
              CategoryBloc(ctx.read<ICategoryRepository>())
                ..add(LoadCategoriesEvent()),
        ),
        BlocProvider(
          create: (ctx) => TransactionBloc(
            ctx.read<ITransactionRepository>(),
            ctx.read<ISavingRepository>(),
          ),
        ),
        BlocProvider(
          create: (ctx) =>
              SavingsBloc(ctx.read<ISavingRepository>())
                ..add(LoadSavingsListEvent()),
        ),
        BlocProvider(
          create: (ctx) {
            final a = args;
            final bloc = TransactionFormBloc();
            if (a?.existingTransaction != null) {
              bloc.add(
                InitializeTransactionFormForEdit(
                  transaction: a!.existingTransaction!,
                  category: a.existingCategory,
                  selectedTime: a.existingTime,
                ),
              );
            } else {
              bloc.add(
                InitializeTransactionForm(preselectedType: a?.preselectedType),
              );
            }
            return bloc;
          },
        ),
      ],
      child: _AddTransactionScreenContent(args: args),
    );
  }
}

// =============================================================================
// Stateful content
// =============================================================================

class _AddTransactionScreenContent extends StatefulWidget {
  final AddTransactionScreenArgs? args;

  const _AddTransactionScreenContent({this.args});

  @override
  State<_AddTransactionScreenContent> createState() =>
      _AddTransactionScreenContentState();
}

class _AddTransactionScreenContentState
    extends State<_AddTransactionScreenContent> {
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _noteController;

  bool _controllersSynced = false;

  bool get _isEditMode => widget.args?.editingTransactionId != null;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _titleController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Sync controllers once on edit mode load
  // ---------------------------------------------------------------------------

  void _syncControllersFromFormState(TransactionFormReady formState) {
    if (_controllersSynced) return;
    if (!formState.isEditMode) {
      _controllersSynced = true;
      return;
    }

    if (formState.amount != null && _amountController.text.isEmpty) {
      _amountController.text = formState.amount!;
    }
    if (formState.title != null && _titleController.text.isEmpty) {
      _titleController.text = formState.title!;
    }
    if (formState.note != null && _noteController.text.isEmpty) {
      _noteController.text = formState.note!;
    }

    _controllersSynced = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionCreated || state is TransactionUpdated) {
            final isEdit = state is TransactionUpdated;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      isEdit
                          ? 'Transaction updated successfully'
                          : 'Transaction added successfully',
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.homeLoggedIn,
              (context) => false,
            );
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<TransactionFormBloc, TransactionFormState>(
              builder: (context, formState) {
                if (formState is! TransactionFormReady) {
                  return const Center(child: CircularProgressIndicator());
                }

                _syncControllersFromFormState(formState);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Locked banner — only in edit mode
                    if (_isEditMode) ...[
                      _buildLockedBanner(),
                      const SizedBox(height: 16),
                    ],

                    // Transaction type — locked in edit, toggle in add
                    _isEditMode
                        ? _buildLockedTypeDisplay(formState)
                        : _buildTransactionTypeToggle(context, formState),
                    const SizedBox(height: 24),

                    // Amount — locked in edit, input in add
                    _isEditMode
                        ? _buildLockedAmountDisplay(formState)
                        : _buildAmountInput(context, formState),
                    const SizedBox(height: 24),

                    // Account — locked in edit, dropdown in add
                    _isEditMode
                        ? _buildLockedAccountDisplay(context, formState)
                        : _buildAccountSelection(context, formState),
                    const SizedBox(height: 16),

                    // Description — always editable
                    _buildTitleInput(context),
                    const SizedBox(height: 16),

                    // Category — locked in edit, grid in add
                    if (formState.transactionType != TransactionType.transfer &&
                        formState.transactionType !=
                            TransactionType.commitment) ...[
                      _isEditMode
                          ? _buildLockedCategoryDisplay(context, formState)
                          : _buildCategoryGrid(context, formState),
                      const SizedBox(height: 16),
                    ],

                    // Date — always editable
                    _buildDatePicker(context, formState),
                    const SizedBox(height: 16),

                    // Time — always editable
                    _buildTimePicker(context, formState),
                    const SizedBox(height: 16),

                    // Note — always editable
                    _buildNoteField(context, formState),
                    const SizedBox(height: 32),

                    _buildSubmitButton(context, formState),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Locked banner
  // ---------------------------------------------------------------------------

  Widget _buildLockedBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Type, amount, and account cannot be changed after a transaction is saved.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Locked display widgets
  // ---------------------------------------------------------------------------

  Widget _buildLockedTypeDisplay(TransactionFormReady formState) {
    final type = formState.transactionType;
    final color = _typeColor(type);

    return _LockedField(
      label: 'Transaction Type',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_typeIcon(type), color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              _typeLabel(type),
              style: AppTextStyles.bodySemiBold.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedAmountDisplay(TransactionFormReady formState) {
    return _LockedField(
      label: 'Amount',
      child: Text(
        'RM ${formState.amount ?? '0.00'}',
        style: AppTextStyles.amountXLarge.copyWith(
          color: _typeColor(formState.transactionType),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLockedAccountDisplay(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final savingsList = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        final sourceName =
            savingsList
                .cast<ListSavingVO?>()
                .firstWhere(
                  (s) => s?.saving.id == formState.selectedSourceAccount,
                  orElse: () => null,
                )
                ?.saving
                .name ??
            formState.selectedSourceAccount ??
            'Unknown';

        if (formState.transactionType == TransactionType.transfer) {
          final destName =
              savingsList
                  .cast<ListSavingVO?>()
                  .firstWhere(
                    (s) => s?.saving.id == formState.selectedDestinationAccount,
                    orElse: () => null,
                  )
                  ?.saving
                  .name ??
              formState.selectedDestinationAccount ??
              'Unknown';

          return _LockedField(
            label: 'Transfer Accounts',
            child: Row(
              children: [
                _accountChip(sourceName, Icons.arrow_upward, AppColors.expense),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                _accountChip(destName, Icons.arrow_downward, AppColors.income),
              ],
            ),
          );
        }

        return _LockedField(
          label: formState.transactionType == TransactionType.income
              ? 'Received Into Account'
              : 'Paid From Account',
          child: _accountChip(
            sourceName,
            Icons.account_balance,
            AppColors.primary,
          ),
        );
      },
    );
  }

  Widget _accountChip(String name, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(name, style: AppTextStyles.bodyMedium.copyWith(color: color)),
        ],
      ),
    );
  }

  Widget _buildLockedCategoryDisplay(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    final category = formState.selectedCategory;
    final typeColor = _typeColor(formState.transactionType);

    if (category == null) {
      return _LockedField(
        label: 'Category',
        child: Text(
          'Uncategorized',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return _LockedField(
      label: 'Category',
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CategoryIconMapper.getIconForCategory(category.iconCodePoint),
              color: typeColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            category.name,
            style: AppTextStyles.bodyMedium.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Transaction type toggle (add mode only)
  // ---------------------------------------------------------------------------

  Widget _buildTransactionTypeToggle(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _TypeToggleItem(
              type: TransactionType.income,
              label: 'Income',
              icon: Icons.arrow_downward_rounded,
              color: AppColors.income,
              isSelected: formState.transactionType == TransactionType.income,
            ),
          ),
          Expanded(
            child: _TypeToggleItem(
              type: TransactionType.expense,
              label: 'Expense',
              icon: Icons.arrow_upward_rounded,
              color: AppColors.expense,
              isSelected: formState.transactionType == TransactionType.expense,
            ),
          ),
          Expanded(
            child: _TypeToggleItem(
              type: TransactionType.transfer,
              label: 'Transfer',
              icon: Icons.swap_horiz_rounded,
              color: AppColors.transfer,
              isSelected: formState.transactionType == TransactionType.transfer,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Amount input (add mode only)
  // ---------------------------------------------------------------------------

  Widget _buildAmountInput(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Amount', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider),
          ),
          child: Row(
            children: [
              Text(
                'RM',
                style: AppTextStyles.amountMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountXLarge.copyWith(
                    color: _typeColor(formState.transactionType),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0.00',
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Account selection (add mode only)
  // ---------------------------------------------------------------------------

  Widget _buildAccountSelection(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return BlocBuilder<SavingsBloc, SavingsState>(
      builder: (context, state) {
        final savingsList = state is SavingsListLoaded
            ? state.savingsList
            : <ListSavingVO>[];

        if (formState.transactionType == TransactionType.transfer) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Transfer Between Accounts',
                style: AppTextStyles.bodySemiBold,
              ),
              const SizedBox(height: 12),
              _AccountDropdown(
                label: 'From Account',
                hint: 'Select source account',
                selectedId: formState.selectedSourceAccount,
                savingsList: savingsList,
                onChanged: (v) => context.read<TransactionFormBloc>().add(
                  SelectSourceAccount(v),
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.arrow_downward,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 12),
              _AccountDropdown(
                label: 'To Account',
                hint: 'Select destination account',
                selectedId: formState.selectedDestinationAccount,
                savingsList: savingsList,
                excludeId: formState.selectedSourceAccount,
                onChanged: (v) => context.read<TransactionFormBloc>().add(
                  SelectDestinationAccount(v),
                ),
              ),
            ],
          );
        }

        final isIncome = formState.transactionType == TransactionType.income;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIncome ? 'Received Into Account' : 'Paid From Account',
              style: AppTextStyles.bodySemiBold,
            ),
            const SizedBox(height: 12),
            _AccountDropdown(
              label: 'Account',
              hint: isIncome
                  ? 'Select account to receive money'
                  : 'Select account used for payment',
              selectedId: formState.selectedSourceAccount,
              savingsList: savingsList,
              onChanged: (v) => context.read<TransactionFormBloc>().add(
                SelectSourceAccount(v),
              ),
            ),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Title (always editable)
  // ---------------------------------------------------------------------------

  Widget _buildTitleInput(BuildContext context) {
    return AppTextField(
      label: 'Description',
      hint: 'What was this for?',
      controller: _titleController,
      prefixIcon: Icons.description_outlined,
    );
  }

  // ---------------------------------------------------------------------------
  // Category grid (add mode only)
  // ---------------------------------------------------------------------------

  Widget _buildCategoryGrid(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: 12),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is! CategoryLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = state.categories.where((c) {
              switch (formState.transactionType) {
                case TransactionType.income:
                  return c.isIncome;
                case TransactionType.expense:
                  return c.isExpense;
                default:
                  return false;
              }
            }).toList();

            if (categories.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: const Text(
                  'No categories found. Add categories in Settings.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected =
                    formState.selectedCategory?.id == category.id;
                final typeColor = _typeColor(formState.transactionType);

                return GestureDetector(
                  onTap: () => context.read<TransactionFormBloc>().add(
                    SelectCategory(category),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? typeColor.withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? typeColor : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? typeColor
                                : typeColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CategoryIconMapper.getIconForCategory(
                              category.iconCodePoint,
                            ),
                            color: isSelected ? Colors.white : typeColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? typeColor
                                : AppColors.textSecondary,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Date picker (always editable)
  // ---------------------------------------------------------------------------

  Widget _buildDatePicker(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: formState.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null && context.mounted) {
          context.read<TransactionFormBloc>().add(
            ChangeTransactionDate(picked),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateDisplay(formState.selectedDate),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);
    if (d == today) return 'Today';
    if (d == yesterday) return 'Yesterday';
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  // ---------------------------------------------------------------------------
  // Time picker (always editable)
  // ---------------------------------------------------------------------------

  Widget _buildTimePicker(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: formState.selectedTime ?? TimeOfDay.now(),
        );
        if (picked != null && context.mounted) {
          context.read<TransactionFormBloc>().add(
            ChangeTransactionTime(picked),
          );
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Time',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formState.selectedTime != null
                      ? formState.selectedTime!.format(context)
                      : 'Not set (uses midnight)',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: formState.selectedTime != null
                        ? AppColors.textPrimary
                        : AppColors.textHint,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Note field (always editable)
  // ---------------------------------------------------------------------------

  Widget _buildNoteField(BuildContext context, TransactionFormReady formState) {
    if (!formState.showNoteField) {
      return AppButton.text(
        label: '+ Add note (optional)',
        icon: Icons.add,
        onPressed: () => context.read<TransactionFormBloc>().add(
          const ToggleNoteField(true),
        ),
      );
    }
    return AppTextField(
      label: 'Note',
      hint: 'Add any additional details',
      controller: _noteController,
      prefixIcon: Icons.note_outlined,
      maxLines: 3,
    );
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Widget _buildSubmitButton(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;
        final isEdit = formState.isEditMode;
        final label = isEdit
            ? (isLoading ? 'Updating...' : 'Update Transaction')
            : (isLoading ? 'Saving...' : 'Save Transaction');

        return AppButton.primary(
          label: label,
          isLoading: isLoading,
          isFullWidth: true,
          onPressed: isLoading ? null : () => _submit(context, formState),
        );
      },
    );
  }

  void _submit(BuildContext context, TransactionFormReady formState) {
    final titleText = _titleController.text.trim();
    final note = _noteController.text.trim().isEmpty
        ? null
        : _noteController.text.trim();

    if (titleText.isEmpty) {
      _showError(context, 'Please enter a description');
      return;
    }

    // Build combined date + time
    DateTime transactionDateTime = formState.selectedDate;
    if (formState.selectedTime != null) {
      transactionDateTime = DateTime(
        formState.selectedDate.year,
        formState.selectedDate.month,
        formState.selectedDate.day,
        formState.selectedTime!.hour,
        formState.selectedTime!.minute,
      );
    }

    if (formState.isEditMode && formState.editingTransactionId != null) {
      // Edit mode — only send editable fields.
      // Bloc will load the existing record and preserve all immutable fields.
      context.read<TransactionBloc>().add(
        UpdateTransactionEvent(
          TransactionEntity(
            id: formState.editingTransactionId!,
            title: titleText,
            date: transactionDateTime,
            note: note,
            // Immutable fields — bloc ignores these and uses existing DB values
            amount: 0,
            type: formState.transactionType,
            savingId: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
      );
      return;
    }

    // Add mode — validate all fields before dispatching
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText);

    if (amountText.isEmpty || amount == null || amount <= 0) {
      _showError(context, 'Please enter a valid amount greater than 0');
      return;
    }
    if (formState.selectedSourceAccount == null) {
      _showError(
        context,
        formState.transactionType == TransactionType.transfer
            ? 'Please select a source account'
            : 'Please select an account',
      );
      return;
    }
    if (formState.transactionType == TransactionType.transfer &&
        formState.selectedDestinationAccount == null) {
      _showError(context, 'Please select a destination account');
      return;
    }
    if (formState.selectedCategory == null &&
        formState.transactionType != TransactionType.transfer &&
        formState.transactionType != TransactionType.commitment) {
      _showError(context, 'Please select a category');
      return;
    }

    context.read<TransactionBloc>().add(
      CreateTransactionEvent(
        title: titleText,
        amount: amount,
        type: formState.transactionType,
        categoryId: formState.selectedCategory?.id ?? 'uncategorized',
        date: formState.selectedDate,
        time: formState.selectedTime,
        note: note,
        sourceAccountId: formState.selectedSourceAccount,
        destinationAccountId:
            formState.transactionType == TransactionType.transfer
            ? formState.selectedDestinationAccount
            : null,
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
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

  String _typeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.commitment:
        return 'Commitment';
    }
  }

  IconData _typeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return Icons.arrow_downward_rounded;
      case TransactionType.expense:
        return Icons.arrow_upward_rounded;
      case TransactionType.transfer:
      case TransactionType.commitment:
        return Icons.swap_horiz_rounded;
    }
  }
}

// =============================================================================
// Locked field wrapper widget
// =============================================================================

class _LockedField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LockedField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 4),
                child,
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.lock_outline, size: 16, color: AppColors.textHint),
        ],
      ),
    );
  }
}

// =============================================================================
// Sub-widgets
// =============================================================================

class _TypeToggleItem extends StatelessWidget {
  final TransactionType type;
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;

  const _TypeToggleItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () =>
          context.read<TransactionFormBloc>().add(ChangeTransactionType(type)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountDropdown extends StatelessWidget {
  final String label;
  final String hint;
  final String? selectedId;
  final List<ListSavingVO> savingsList;
  final String? excludeId;
  final ValueChanged<String?> onChanged;

  const _AccountDropdown({
    required this.label,
    required this.hint,
    required this.selectedId,
    required this.savingsList,
    this.excludeId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final available = savingsList
        .where((s) => s.saving.id != excludeId)
        .toList();

    if (available.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text(
          'No savings accounts available. Please add one first.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    // Guard against assertion crash when savings load async
    final validSelectedId = available.any((s) => s.saving.id == selectedId)
        ? selectedId
        : null;

    return DropdownButtonFormField<String>(
      initialValue: validSelectedId,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.account_balance),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: available.map((s) {
        return DropdownMenuItem<String>(
          value: s.saving.id,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _savingIcon(s.saving.type),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${s.saving.name ?? 'Unnamed'} · RM ${s.saving.currentAmount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _savingIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cash':
        return const Icon(Icons.money, color: AppColors.success, size: 20);
      case 'bank':
      case 'bank_account':
        return const Icon(
          Icons.account_balance,
          color: AppColors.primary,
          size: 20,
        );
      case 'credit':
      case 'credit_card':
        return const Icon(
          Icons.credit_card,
          color: AppColors.secondary,
          size: 20,
        );
      case 'ewallet':
      case 'e_wallet':
        return const Icon(
          Icons.phone_android,
          color: AppColors.tertiary,
          size: 20,
        );
      case 'savings':
        return const Icon(Icons.savings, color: AppColors.income, size: 20);
      default:
        return const Icon(Icons.account_balance_wallet, size: 20);
    }
  }
}
