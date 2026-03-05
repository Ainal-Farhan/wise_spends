import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
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

/// Arguments for AddTransactionScreen
class AddTransactionScreenArgs {
  final TransactionType? preselectedType;

  const AddTransactionScreenArgs({this.preselectedType});
}

/// Enhanced Add Transaction Screen - Pure BLoC
class AddTransactionScreen extends StatelessWidget {
  final AddTransactionScreenArgs? args;

  const AddTransactionScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              CategoryBloc(context.read<ICategoryRepository>())
                ..add(LoadCategoriesEvent()),
        ),
        BlocProvider(
          create: (context) =>
              TransactionBloc(context.read<ITransactionRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              SavingsBloc(context.read<ISavingRepository>())
                ..add(LoadSavingsListEvent()),
        ),
        BlocProvider(
          create: (context) => TransactionFormBloc()
            ..add(
              InitializeTransactionForm(preselectedType: args?.preselectedType),
            ),
        ),
      ],
      child: const _AddTransactionScreenContent(),
    );
  }
}

class _AddTransactionScreenContent extends StatelessWidget {
  const _AddTransactionScreenContent();

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();
    final titleController = TextEditingController();
    final noteController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {
          if (state is TransactionCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Transaction added successfully'),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
            Navigator.pop(context);
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
              builder: (context, state) {
                if (state is! TransactionFormReady) {
                  return const Center(child: CircularProgressIndicator());
                }

                final formState = state;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Transaction Type Toggle
                    _buildTransactionTypeToggle(context, formState),
                    const SizedBox(height: 24),

                    // Amount Input
                    _buildAmountInput(context, formState, amountController),
                    const SizedBox(height: 24),

                    // Account Selection
                    _buildAccountSelection(context, formState),
                    const SizedBox(height: 16),

                    // Title Input
                    _buildTitleInput(context, titleController),
                    const SizedBox(height: 16),

                    // Category Grid
                    if (formState.transactionType != TransactionType.transfer)
                      _buildCategoryGrid(context, formState),

                    // Date Picker
                    _buildDatePicker(context, formState),
                    const SizedBox(height: 16),

                    // Note Field
                    _buildNoteField(context, formState, noteController),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(
                      context,
                      formState,
                      amountController,
                      titleController,
                      noteController,
                    ),
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
            child: _buildTypeToggleItem(
              context,
              type: TransactionType.income,
              label: 'Income',
              icon: Icons.arrow_downward_rounded,
              color: AppColors.income,
              isSelected: formState.transactionType == TransactionType.income,
            ),
          ),
          Expanded(
            child: _buildTypeToggleItem(
              context,
              type: TransactionType.expense,
              label: 'Expense',
              icon: Icons.arrow_upward_rounded,
              color: AppColors.expense,
              isSelected: formState.transactionType == TransactionType.expense,
            ),
          ),
          Expanded(
            child: _buildTypeToggleItem(
              context,
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

  Widget _buildTypeToggleItem(
    BuildContext context, {
    required TransactionType type,
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        context.read<TransactionFormBloc>().add(ChangeTransactionType(type));
      },
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

  Widget _buildAmountInput(
    BuildContext context,
    TransactionFormReady formState,
    TextEditingController controller,
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
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: AppTextStyles.amountXLarge.copyWith(
                    color: _getAmountColor(formState.transactionType),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
                      return 'Amount must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAmountColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  Widget _buildAccountSelection(
    BuildContext context,
    TransactionFormReady formState,
  ) {
    if (formState.transactionType == TransactionType.transfer) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transfer Between Accounts', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 12),
          BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, state) {
              List<ListSavingVO> savingsList = [];
              if (state is SavingsListLoaded) {
                savingsList = state.savingsList;
              }

              return Column(
                children: [
                  _buildAccountDropdown(
                    label: 'From Account',
                    hint: 'Select source account',
                    selectedAccountId: formState.selectedSourceAccount,
                    savingsList: savingsList,
                    onChanged: (value) {
                      context.read<TransactionFormBloc>().add(
                        SelectSourceAccount(value),
                      );
                    },
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
                  _buildAccountDropdown(
                    label: 'To Account',
                    hint: 'Select destination account',
                    selectedAccountId: formState.selectedDestinationAccount,
                    savingsList: savingsList,
                    excludeAccountId: formState.selectedSourceAccount,
                    onChanged: (value) {
                      context.read<TransactionFormBloc>().add(
                        SelectDestinationAccount(value),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      );
    } else {
      final isIncome = formState.transactionType == TransactionType.income;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIncome ? 'Received Into Account' : 'Paid From Account',
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 12),
          BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, state) {
              List<ListSavingVO> savingsList = [];
              if (state is SavingsListLoaded) {
                savingsList = state.savingsList;
              }

              return _buildAccountDropdown(
                label: 'Account',
                hint: isIncome
                    ? 'Select account to receive money'
                    : 'Select account used for payment',
                selectedAccountId: formState.selectedSourceAccount,
                savingsList: savingsList,
                onChanged: (value) {
                  context.read<TransactionFormBloc>().add(
                    SelectSourceAccount(value),
                  );
                },
              );
            },
          ),
        ],
      );
    }
  }

  Widget _buildAccountDropdown({
    required String label,
    required String hint,
    required String? selectedAccountId,
    required List<ListSavingVO> savingsList,
    String? excludeAccountId,
    required ValueChanged<String?> onChanged,
  }) {
    final availableAccounts = savingsList
        .where((s) => s.saving.id != excludeAccountId)
        .toList();

    if (availableAccounts.isEmpty) {
      return const Text(
        'No savings accounts available. Please add a savings account first.',
        style: TextStyle(color: AppColors.textSecondary),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: selectedAccountId,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: const Icon(Icons.account_balance),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: availableAccounts.map((saving) {
        return DropdownMenuItem<String>(
          value: saving.saving.id,
          child: Row(
            children: [
              _getAccountIcon(saving.saving.type),
              const SizedBox(width: 8),
              Text(saving.saving.name ?? 'Unnamed'),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return 'Please select an account';
        }
        return null;
      },
    );
  }

  Widget _getAccountIcon(String type) {
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

  Widget _buildTitleInput(
    BuildContext context,
    TextEditingController controller,
  ) {
    return AppTextField(
      label: 'Description',
      hint: 'What was this for?',
      controller: controller,
      prefixIcon: Icons.description_outlined,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
    );
  }

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
            List<CategoryEntity> categories = [];

            if (state is CategoryLoaded) {
              categories = state.categories
                  .where(
                    (c) => _isCategoryForTransactionType(
                      c,
                      formState.transactionType,
                    ),
                  )
                  .toList();
            }

            if (categories.isEmpty) {
              return const Text('No categories available');
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

                return GestureDetector(
                  onTap: () {
                    context.read<TransactionFormBloc>().add(
                      SelectCategory(category),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? _getTypeColor(
                              formState.transactionType,
                            ).withValues(alpha: 0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? _getTypeColor(formState.transactionType)
                            : AppColors.divider,
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
                                ? _getTypeColor(formState.transactionType)
                                : _getTypeColor(
                                    formState.transactionType,
                                  ).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getCategoryIconData(category.iconCodePoint),
                            color: isSelected
                                ? Colors.white
                                : _getTypeColor(formState.transactionType),
                            size: 20,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          category.name,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: isSelected
                                ? _getTypeColor(formState.transactionType)
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

  bool _isCategoryForTransactionType(
    CategoryEntity category,
    TransactionType type,
  ) {
    switch (type) {
      case TransactionType.income:
        return category.isIncome || (!category.isIncome && !category.isExpense);
      case TransactionType.expense:
        return category.isExpense ||
            (!category.isIncome && !category.isExpense);
      case TransactionType.transfer:
        return false;
    }
  }

  Color _getTypeColor(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
    }
  }

  IconData _getCategoryIconData(String? iconCodePoint) {
    if (iconCodePoint == null) return Icons.category_rounded;
    return CategoryIconMapper.getIconForCategory(iconCodePoint);
  }

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
        if (picked != null) {
          context.read<TransactionFormBloc>().add(
            ChangeTransactionDate(picked),
          );
        }
      },
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
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    }
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  Widget _buildNoteField(
    BuildContext context,
    TransactionFormReady formState,
    TextEditingController controller,
  ) {
    if (!formState.showNoteField) {
      return AppButton.text(
        label: '+ Add note (optional)',
        icon: Icons.add,
        onPressed: () {
          context.read<TransactionFormBloc>().add(const ToggleNoteField(true));
        },
      );
    }

    return AppTextField(
      label: 'Note',
      hint: 'Add any additional details',
      controller: controller,
      prefixIcon: Icons.note_outlined,
      maxLines: 3,
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    TransactionFormReady formState,
    TextEditingController amountController,
    TextEditingController titleController,
    TextEditingController noteController,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;

        return AppButton.primary(
          label: isLoading ? 'Saving...' : 'Save Transaction',
          onPressed: isLoading
              ? null
              : () => _submitTransaction(
                  context,
                  formState,
                  amountController,
                  titleController,
                  noteController,
                ),
          isLoading: isLoading,
          isFullWidth: true,
        );
      },
    );
  }

  void _submitTransaction(
    BuildContext context,
    TransactionFormReady formState,
    TextEditingController amountController,
    TextEditingController titleController,
    TextEditingController noteController,
  ) {
    if (amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a description'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (formState.selectedSourceAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            formState.transactionType == TransactionType.transfer
                ? 'Please select source account'
                : 'Please select an account',
          ),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (formState.transactionType == TransactionType.transfer &&
        formState.selectedDestinationAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select destination account'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (formState.selectedCategory == null &&
        formState.transactionType != TransactionType.transfer) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final amount = double.parse(amountController.text);

    context.read<TransactionBloc>().add(
      CreateTransactionEvent(
        title: titleController.text,
        amount: amount,
        type: formState.transactionType,
        categoryId: formState.selectedCategory?.id ?? 'uncategorized',
        date: formState.selectedDate,
        note: noteController.text.isEmpty ? null : noteController.text,
        sourceAccountId: formState.selectedSourceAccount,
        destinationAccountId:
            formState.transactionType == TransactionType.transfer
            ? formState.selectedDestinationAccount
            : null,
      ),
    );
  }
}
