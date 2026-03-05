import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_event.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:wise_spends/presentation/blocs/transaction/transaction_event.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Add Spending Bottom Sheet
/// Quick entry for adding spending/transactions to a budget plan
class AddSpendingBottomSheet extends StatefulWidget {
  final String planUuid;

  const AddSpendingBottomSheet({super.key, required this.planUuid});

  @override
  State<AddSpendingBottomSheet> createState() => _AddSpendingBottomSheetState();
}

class _AddSpendingBottomSheetState extends State<AddSpendingBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _vendorController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategory;
  bool _linkToMainTransaction = false;
  String? _receiptPath;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Container(
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: WiseSpendsColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              loc.get('budget_plans.add_spending'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Amount Input (Large)
            _buildAmountInput(),
            const SizedBox(height: 24),

            // Description
            _buildDescriptionField(),
            const SizedBox(height: 16),

            // Vendor
            _buildVendorField(),
            const SizedBox(height: 16),

            // Category Chips
            _buildCategorySelector(),
            const SizedBox(height: 16),

            // Date Picker
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Attach Receipt
            _buildAttachReceipt(),
            const SizedBox(height: 16),

            // Link to Main Transaction Toggle
            _buildLinkToggle(),
            const SizedBox(height: 24),

            // Submit Button
            _buildSubmitButton(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: WiseSpendsColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: WiseSpendsColors.divider),
          ),
          child: Row(
            children: [
              Text(
                'RM',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WiseSpendsColors.textSecondary,
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: WiseSpendsColors.secondary,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  autofocus: true,
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

  Widget _buildDescriptionField() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('general.description'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText: 'What was this for?',
            prefixIcon: Icon(Icons.description_outlined),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return loc.get('error.validation.required');
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVendorField() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('budget_plans.vendor'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _vendorController,
          decoration: InputDecoration(
            hintText: loc.get('budget_plans.vendor_hint'),
            prefixIcon: const Icon(Icons.store_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('general.category'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildCategoryChip('Venue', 'venue', Icons.celebration),
            _buildCategoryChip('Catering', 'catering', Icons.restaurant),
            _buildCategoryChip('Decor', 'decor', Icons.local_florist),
            _buildCategoryChip('Attire', 'attire', Icons.checkroom),
            _buildCategoryChip('Photography', 'photography', Icons.camera_alt),
            _buildCategoryChip('Other', 'other', Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, String value, IconData icon) {
    final isSelected = _selectedCategory == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedCategory = selected ? value : null;
        });
      },
      selectedColor: WiseSpendsColors.secondary.withValues(alpha: 0.2),
      checkmarkColor: WiseSpendsColors.secondary,
    );
  }

  Widget _buildDatePicker() {
    final loc = LocalizationService();

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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WiseSpendsColors.divider),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              color: WiseSpendsColors.textSecondary,
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.get('general.date'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: WiseSpendsColors.textHint,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMMM d, y').format(_selectedDate),
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

  Widget _buildAttachReceipt() {
    final loc = LocalizationService();

    return InkWell(
      onTap: () async {
        try {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );

          if (result != null && result.files.single.path != null) {
            // File picked successfully
            setState(() {
              _receiptPath = result.files.single.path;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Receipt attached: ${result.files.single.name}'),
                backgroundColor: WiseSpendsColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to pick receipt: ${e.toString()}'),
              backgroundColor: WiseSpendsColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: WiseSpendsColors.divider),
        ),
        child: Row(
          children: [
            Icon(Icons.attach_file, color: WiseSpendsColors.textSecondary),
            const SizedBox(width: 16),
            Text(
              loc.get('budget_plans.attach_receipt'),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
            const Spacer(),
            Icon(Icons.add_a_photo, color: WiseSpendsColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Also add to main transactions',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                'Create a linked transaction in main ledger',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WiseSpendsColors.textHint,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: _linkToMainTransaction,
          onChanged: (value) {
            setState(() {
              _linkToMainTransaction = value;
            });
          },
          activeThumbColor: WiseSpendsColors.primary,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final loc = LocalizationService();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitSpending,
        style: ElevatedButton.styleFrom(
          backgroundColor: WiseSpendsColors.secondary,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Text(loc.get('budget_plans.add_spending')),
      ),
    );
  }

  void _submitSpending() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      context.read<BudgetPlanDetailBloc>().add(
        AddSpending(
          amount: amount,
          description: _descriptionController.text,
          vendor: _vendorController.text.isEmpty
              ? null
              : _vendorController.text,
          transactionDate: _selectedDate,
          receiptPath: _receiptPath,
        ),
      );

      // If _linkToMainTransaction is true, also create main transaction
      if (_linkToMainTransaction) {
        // Create corresponding transaction in main ledger
        // This creates a regular expense transaction linked to this plan
        context.read<TransactionBloc>().add(
          CreateTransactionEvent(
            title: _descriptionController.text,
            amount: amount,
            type: TransactionType.expense,
            categoryId: 'budget_plan',
            date: _selectedDate,
            note: 'Linked to budget plan: ${widget.planUuid}',
          ),
        );
      }

      Navigator.pop(context);
    }
  }
}
