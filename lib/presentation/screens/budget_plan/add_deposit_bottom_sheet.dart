import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/entities/budget_plan/linked_account_entity.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_detail/budget_plan_detail_event.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Add Deposit Bottom Sheet
/// Quick entry for adding deposits to a budget plan
class AddDepositBottomSheet extends StatefulWidget {
  final String planUuid;

  const AddDepositBottomSheet({super.key, required this.planUuid});

  @override
  State<AddDepositBottomSheet> createState() => _AddDepositBottomSheetState();
}

class _AddDepositBottomSheetState extends State<AddDepositBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedSource = 'manual';
  DateTime _selectedDate = DateTime.now();
  int? _selectedAccountId;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
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
              loc.get('budget_plans.add_deposit'),
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),

            // Amount Input (Large)
            _buildAmountInput(),
            const SizedBox(height: 24),

            // Source Selector
            _buildSourceSelector(),
            const SizedBox(height: 16),

            // Account Selector (if From Account selected)
            if (_selectedSource == 'linked_account') ...[
              _buildAccountSelector(),
              const SizedBox(height: 16),
            ],

            // Date Picker
            _buildDatePicker(),
            const SizedBox(height: 16),

            // Note Field
            _buildNoteField(),
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
                    color: WiseSpendsColors.success,
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

  Widget _buildSourceSelector() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('budget_plans.deposit_source'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildSourceChip('Manual', 'manual', Icons.edit),
            _buildSourceChip(
              'From Account',
              'linked_account',
              Icons.account_balance,
            ),
            _buildSourceChip('Salary', 'salary', Icons.work),
            _buildSourceChip('Bonus', 'bonus', Icons.card_giftcard),
            _buildSourceChip('Other', 'other', Icons.more_horiz),
          ],
        ),
      ],
    );
  }

  Widget _buildSourceChip(String label, String value, IconData icon) {
    final isSelected = _selectedSource == value;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 4), Text(label)],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSource = value;
        });
      },
      selectedColor: WiseSpendsColors.success.withValues(alpha: 0.2),
      checkmarkColor: WiseSpendsColors.success,
    );
  }

  Widget _buildAccountSelector() {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return FutureBuilder<List<LinkedAccountSummaryEntity>>(
      future: repository.watchLinkedAccounts(widget.planUuid).first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final accounts = snapshot.data ?? [];

        if (accounts.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('No linked accounts available'),
          );
        }

        return DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Select Account',
            prefixIcon: Icon(Icons.account_balance),
          ),
          initialValue: _selectedAccountId,
          items: accounts.map((account) {
            return DropdownMenuItem(
              value: account.accountId,
              child: Text(
                '${account.accountName} - RM ${(account.allocatedAmount).toStringAsFixed(2)}',
              ),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAccountId = value;
            });
          },
        );
      },
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

  Widget _buildNoteField() {
    final loc = LocalizationService();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.get('general.note'),
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add any additional details (optional)',
            prefixIcon: Icon(Icons.note_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    final loc = LocalizationService();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitDeposit,
        style: ElevatedButton.styleFrom(
          backgroundColor: WiseSpendsColors.success,
          minimumSize: const Size(double.infinity, 48),
        ),
        child: Text(loc.get('budget_plans.add_deposit')),
      ),
    );
  }

  void _submitDeposit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_amountController.text);

      context.read<BudgetPlanDetailBloc>().add(
        AddDeposit(
          amount: amount,
          note: _noteController.text.isEmpty ? null : _noteController.text,
          source: _selectedSource,
          depositDate: _selectedDate,
          linkedAccountId: _selectedAccountId,
        ),
      );

      Navigator.pop(context);
    }
  }
}
