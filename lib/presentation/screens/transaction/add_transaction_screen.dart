import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/domain/repositories/category_repository.dart';
import 'package:wise_spends/presentation/blocs/category/category_bloc.dart';
import 'package:wise_spends/presentation/blocs/category/category_event.dart';
import 'package:wise_spends/presentation/blocs/category/category_state.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_state.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';
import 'package:wise_spends/shared/utils/category_icon_mapper.dart';

/// Arguments for AddTransactionScreen
class AddTransactionScreenArgs {
  final TransactionType? preselectedType;

  const AddTransactionScreenArgs({this.preselectedType});
}

/// Enhanced Add Transaction Screen
/// Features:
/// - Toggle for Income/Expense/Transfer at top
/// - Large amount input (calculator-style)
/// - Category grid selection (not dropdown)
/// - Date picker with relative labels
/// - Optional note field (collapsible)
/// - Running total display
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
      ],
      child: _AddTransactionScreenContent(
        preselectedType: args?.preselectedType,
      ),
    );
  }
}

class _AddTransactionScreenContent extends StatefulWidget {
  final TransactionType? preselectedType;

  const _AddTransactionScreenContent({this.preselectedType});

  @override
  State<_AddTransactionScreenContent> createState() =>
      _AddTransactionScreenContentState();
}

class _AddTransactionScreenContentState
    extends State<_AddTransactionScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();

  TransactionType _transactionType = TransactionType.expense;
  CategoryEntity? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _showNoteField = false;

  @override
  void initState() {
    super.initState();
    if (widget.preselectedType != null) {
      _transactionType = widget.preselectedType!;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
          constraints: const BoxConstraints(
            minWidth: UIConstants.touchTargetMin,
            minHeight: UIConstants.touchTargetMin,
          ),
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
                    SizedBox(width: 12),
                    Text('Transaction added successfully'),
                  ],
                ),
                backgroundColor: WiseSpendsColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
                ),
              ),
            );
            Navigator.pop(context);
          } else if (state is TransactionDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Transaction deleted'),
                backgroundColor: WiseSpendsColors.textPrimary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                ),
                action: SnackBarAction(
                  label: 'Undo',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<TransactionBloc>().undoDelete(state.transactionId);
                  },
                ),
              ),
            );
          } else if (state is TransactionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: WiseSpendsColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
                ),
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UIConstants.spacingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Transaction Type Toggle
                  _buildTransactionTypeToggle(context),
                  const SizedBox(height: UIConstants.spacingXXL),

                  // Amount Input (Large, prominent)
                  _buildAmountInput(context),
                  const SizedBox(height: UIConstants.spacingXXL),

                  // Title Input
                  _buildTitleInput(context),
                  const SizedBox(height: UIConstants.spacingLarge),

                  // Category Grid
                  _buildCategoryGrid(context),
                  const SizedBox(height: UIConstants.spacingLarge),

                  // Date Picker
                  _buildDatePicker(context),
                  const SizedBox(height: UIConstants.spacingMedium),

                  // Note Field (Collapsible)
                  _buildNoteField(context),
                  const SizedBox(height: UIConstants.spacingXXXL),

                  // Submit Button
                  _buildSubmitButton(context),
                  const SizedBox(height: UIConstants.spacingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      padding: const EdgeInsets.all(UIConstants.spacingXS),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeToggleItem(
              context,
              type: TransactionType.income,
              label: 'Income',
              icon: Icons.arrow_downward_rounded,
              color: WiseSpendsColors.success,
            ),
          ),
          Expanded(
            child: _buildTypeToggleItem(
              context,
              type: TransactionType.expense,
              label: 'Expense',
              icon: Icons.arrow_upward_rounded,
              color: WiseSpendsColors.secondary,
            ),
          ),
          Expanded(
            child: _buildTypeToggleItem(
              context,
              type: TransactionType.transfer,
              label: 'Transfer',
              icon: Icons.swap_horiz_rounded,
              color: WiseSpendsColors.tertiary,
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
  }) {
    final isSelected = _transactionType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _transactionType = type;
          _selectedCategory = null; // Reset category when type changes
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: UIConstants.spacingLarge),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : color,
              size: UIConstants.iconLarge,
            ),
            const SizedBox(height: UIConstants.spacingXS),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingLarge,
            vertical: UIConstants.spacingMedium,
          ),
          decoration: BoxDecoration(
            color: WiseSpendsColors.surface,
            borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
            border: Border.all(color: WiseSpendsColors.divider),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'RM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
              const SizedBox(width: UIConstants.spacingSmall),
              Expanded(
                child: TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _getAmountColor(),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
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

  Color _getAmountColor() {
    switch (_transactionType) {
      case TransactionType.income:
        return WiseSpendsColors.success;
      case TransactionType.expense:
        return WiseSpendsColors.secondary;
      case TransactionType.transfer:
        return WiseSpendsColors.tertiary;
    }
  }

  Widget _buildTitleInput(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            hintText: 'What was this for?',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: UIConstants.spacingMedium),
        BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            List<CategoryEntity> categories = [];

            if (state is CategoryLoaded) {
              categories = state.categories
                  .where((c) => _isCategoryForTransactionType(c))
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
                crossAxisSpacing: UIConstants.spacingMedium,
                mainAxisSpacing: UIConstants.spacingMedium,
                childAspectRatio: 0.85,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final isSelected = _selectedCategory?.id == category.id;

                return _buildCategoryItem(
                  context,
                  category: category,
                  isSelected: isSelected,
                );
              },
            );
          },
        ),
      ],
    );
  }

  bool _isCategoryForTransactionType(CategoryEntity category) {
    switch (_transactionType) {
      case TransactionType.income:
        return category.isIncome || (!category.isIncome && !category.isExpense);
      case TransactionType.expense:
        return category.isExpense ||
            (!category.isIncome && !category.isExpense);
      case TransactionType.transfer:
        return false; // Transfers don't need categories
    }
  }

  Widget _buildCategoryItem(
    BuildContext context, {
    required CategoryEntity category,
    required bool isSelected,
  }) {
    final color = _transactionType == TransactionType.income
        ? WiseSpendsColors.success
        : WiseSpendsColors.secondary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
          border: Border.all(
            color: isSelected ? color : WiseSpendsColors.divider,
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
                color: isSelected ? color : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getCategoryIconData(category.iconCodePoint),
                color: isSelected ? Colors.white : color,
                size: UIConstants.iconMedium,
              ),
            ),
            const SizedBox(height: UIConstants.spacingSmall),
            Text(
              category.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? color : WiseSpendsColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIconData(String? iconCodePoint) {
    if (iconCodePoint == null) return Icons.category_rounded;
    return CategoryIconMapper.getIconForCategory(iconCodePoint);
  }

  Widget _buildDatePicker(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) {
          setState(() {
            _selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(UIConstants.spacingLarge),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
          border: Border.all(color: WiseSpendsColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: WiseSpendsColors.textSecondary,
            ),
            const SizedBox(width: UIConstants.spacingLarge),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Date',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WiseSpendsColors.textHint,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatDateDisplay(_selectedDate),
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right,
              color: WiseSpendsColors.textSecondary,
            ),
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

  Widget _buildNoteField(BuildContext context) {
    if (!_showNoteField) {
      return TextButton(
        onPressed: () {
          setState(() {
            _showNoteField = true;
          });
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 18),
            SizedBox(width: 8),
            Text('Add note (optional)'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: UIConstants.spacingSmall),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any additional details',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        final isLoading = state is TransactionLoading;

        return ElevatedButton(
          onPressed: isLoading ? null : _submitTransaction,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.spacingLarge,
            ),
            minimumSize: const Size(
              double.infinity,
              UIConstants.touchTargetMin,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save Transaction'),
        );
      },
    );
  }

  void _submitTransaction() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategory == null &&
          _transactionType != TransactionType.transfer) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a category'),
            backgroundColor: WiseSpendsColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final amount = double.parse(_amountController.text);

      context.read<TransactionBloc>().add(
        CreateTransactionEvent(
          title: _titleController.text,
          amount: amount,
          type: _transactionType,
          categoryId: _selectedCategory?.id ?? 'uncategorized',
          date: _selectedDate,
          note: _noteController.text.isEmpty ? null : _noteController.text,
        ),
      );
    }
  }
}
