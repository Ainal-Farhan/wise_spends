import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/linked_account_entity.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_bloc.dart';
import 'package:wise_spends/features/transaction/presentation/bloc/transaction_event.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Constants for budget plan spending categories
class _BudgetPlanSpendingCategories {
  static const String venue = 'venue';
  static const String catering = 'catering';
  static const String decor = 'decor';
  static const String attire = 'attire';
  static const String photography = 'photography';
  static const String other = 'other';
}

/// Constants for date picker limits
class _DatePickerLimits {
  static const int firstYear = 2020;
}

/// Add Deposit Bottom Sheet
/// Quick entry for adding deposits to a budget plan.
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
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              const _BottomSheetHandle(),
              const SizedBox(height: AppSpacing.xxl),

              // Title using SectionHeader
              SectionHeader(
                title: 'budget_plans.add_deposit'.tr,
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: AppIconSize.md,
                  ),
                ),
                showDivider: true,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Amount input
              _AmountInputField(
                controller: _amountController,
                accentColor: Theme.of(context).colorScheme.primary,
                labelKey: 'general.amount',
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Source selector
              SectionHeaderCompact(title: 'budget_plans.deposit_source'.tr),
              const SizedBox(height: AppSpacing.sm),
              _SourceChipSelector(
                selected: _selectedSource,
                accentColor: Theme.of(context).colorScheme.primary,
                sources: const [
                  _SourceOption(
                    'manual',
                    Icons.edit,
                    'budget_plans.source_manual',
                  ),
                  _SourceOption(
                    'linked_account',
                    Icons.account_balance,
                    'budget_plans.source_account',
                  ),
                  _SourceOption(
                    'salary',
                    Icons.work,
                    'budget_plans.source_salary',
                  ),
                  _SourceOption(
                    'bonus',
                    Icons.card_giftcard,
                    'budget_plans.source_bonus',
                  ),
                  _SourceOption(
                    'other',
                    Icons.more_horiz,
                    'budget_plans.source_other',
                  ),
                ],
                onChanged: (v) => setState(() => _selectedSource = v),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Account selector (conditional)
              if (_selectedSource == 'linked_account') ...[
                _LinkedAccountSelector(
                  planUuid: widget.planUuid,
                  selectedId: _selectedAccountId,
                  onChanged: (v) => setState(() => _selectedAccountId = v),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // Date picker
              _DatePickerField(
                selectedDate: _selectedDate,
                onChanged: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Note field
              _NoteField(controller: _noteController),
              const SizedBox(height: AppSpacing.xxl),

              // Submit
              AppButton.primary(
                label: 'budget_plans.add_deposit'.tr,
                icon: Icons.add_circle_outline,
                onPressed: _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
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

// =============================================================================
// Add Spending Bottom Sheet
// =============================================================================

/// Add Spending Bottom Sheet
/// Quick entry for adding spending/transactions to a budget plan.
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
  String? _selectedAccountId;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _vendorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _BottomSheetHandle(),
              const SizedBox(height: AppSpacing.xxl),

              // Title using SectionHeader
              SectionHeader(
                title: 'budget_plans.add_spending'.tr,
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: Theme.of(context).colorScheme.secondary,
                    size: AppIconSize.md,
                  ),
                ),
                showDivider: true,
              ),
              const SizedBox(height: AppSpacing.xxl),

              _AmountInputField(
                controller: _amountController,
                accentColor: Theme.of(context).colorScheme.secondary,
                labelKey: 'general.amount',
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Description
              AppTextField(
                label: 'general.description'.tr,
                hint: 'budget_plans.description_hint'.tr,
                controller: _descriptionController,
                prefixIcon: Icons.description_outlined,
                validator: (v) => (v == null || v.isEmpty)
                    ? 'error.validation.required'.tr
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Vendor
              AppTextField(
                label: 'budget_plans.vendor'.tr,
                hint: 'budget_plans.vendor_hint'.tr,
                controller: _vendorController,
                prefixIcon: Icons.store_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category
              SectionHeaderCompact(title: 'general.category'.tr),
              const SizedBox(height: AppSpacing.sm),
              _SpendingCategoryChips(
                selected: _selectedCategory,
                onChanged: (v) => setState(() => _selectedCategory = v),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Date picker
              _DatePickerField(
                selectedDate: _selectedDate,
                onChanged: (d) => setState(() => _selectedDate = d),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Linked Account Selector (optional)
              SectionHeaderCompact(
                title: 'budget_plans.select_linked_account'.tr,
              ),
              const SizedBox(height: AppSpacing.sm),
              _LinkedAccountSelector(
                planUuid: widget.planUuid,
                selectedId: _selectedAccountId,
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'budget_plans.linked_account_optional'.tr,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Attach receipt
              _AttachReceiptTile(
                receiptPath: _receiptPath,
                planUuid: widget.planUuid,
                onAttached: (path) => setState(() => _receiptPath = path),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Link toggle
              _LinkTransactionToggle(
                value: _linkToMainTransaction,
                onChanged: (v) => setState(() => _linkToMainTransaction = v),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton.primary(
                label: 'budget_plans.add_spending'.tr,
                icon: Icons.remove_circle_outline,
                onPressed: _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    context.read<BudgetPlanDetailBloc>().add(
      AddSpending(
        amount: amount,
        description: _descriptionController.text,
        vendor: _vendorController.text.isEmpty ? null : _vendorController.text,
        transactionDate: _selectedDate,
        receiptPath: _receiptPath,
        linkedAccountId: _selectedAccountId,
      ),
    );

    if (_linkToMainTransaction && _selectedAccountId != null) {
      // Guard: TransactionBloc may not be provided in all entry points
      final transactionBloc = context.read<TransactionBloc?>();
      transactionBloc?.add(
        CreateTransactionEvent(
          title: _descriptionController.text,
          amount: amount,
          type: TransactionType.expense,
          categoryId: 'budget_plan',
          date: _selectedDate,
          note: 'budget_plans.linked_note'.trWith({'uuid': widget.planUuid}),
        ),
      );
    }

    Navigator.pop(context);
  }
}

// =============================================================================
// Shared sub-widgets
// =============================================================================

class _BottomSheetHandle extends StatelessWidget {
  const _BottomSheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outline,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Large currency amount input shared between deposit and spending sheets.
class _AmountInputField extends StatelessWidget {
  final TextEditingController controller;
  final Color accentColor;
  final String labelKey;

  const _AmountInputField({
    required this.controller,
    required this.accentColor,
    required this.labelKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelKey.tr,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: Theme.of(context).colorScheme.outline),
          ),
          child: Row(
            children: [
              Text(
                'RM',
                style: AppTextStyles.amountMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.right,
                  autofocus: true,
                  style: AppTextStyles.amountMedium.copyWith(
                    color: accentColor,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'error.validation.required'.tr;
                    }
                    if (double.tryParse(value) == null) {
                      return 'error.validation.invalid_number'.tr;
                    }
                    if (double.parse(value) <= 0) {
                      return 'error.validation.amount_positive'.tr;
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
}

class _SourceOption {
  final String value;
  final IconData icon;
  final String labelKey;

  const _SourceOption(this.value, this.icon, this.labelKey);
}

class _SourceChipSelector extends StatelessWidget {
  final String selected;
  final Color accentColor;
  final List<_SourceOption> sources;
  final ValueChanged<String> onChanged;

  const _SourceChipSelector({
    required this.selected,
    required this.accentColor,
    required this.sources,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: sources.map((s) {
        final isSelected = selected == s.value;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.icon, size: 16),
              const SizedBox(width: 4),
              Text(s.labelKey.tr),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(s.value),
          selectedColor: accentColor.withValues(alpha: 0.2),
          checkmarkColor: accentColor,
        );
      }).toList(),
    );
  }
}

class _LinkedAccountSelector extends StatelessWidget {
  final String planUuid;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _LinkedAccountSelector({
    required this.planUuid,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
        .getBudgetPlanRepository();

    return FutureBuilder<List<LinkedAccountSummaryEntity>>(
      future: repository.watchLinkedAccounts(planUuid).first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ShimmerCard(height: 56);
        }

        final accounts = snapshot.data ?? [];
        if (accounts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              'budget_plans.no_linked_accounts'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'budget_plans.select_account'.tr,
            prefixIcon: const Icon(Icons.account_balance),
          ),
          initialValue: selectedId,
          items: accounts
              .map(
                (a) => DropdownMenuItem<String>(
                  value: a.accountId,
                  child: Text(
                    '${a.accountName} · RM ${a.allocatedAmount.toStringAsFixed(2)}',
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        );
      },
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({required this.selectedDate, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(_DatePickerLimits.firstYear),
          lastDate: DateTime.now(),
        );
        if (picked != null) onChanged(picked);
      },
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: AppIconSize.md,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'general.date'.tr,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(selectedDate),
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;

  const _NoteField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: 'general.note'.tr,
      hint: 'budget_plans.note_hint'.tr,
      controller: controller,
      maxLines: 3,
      prefixIcon: Icons.note_outlined,
    );
  }
}

class _SpendingCategoryChips extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  // Each entry: (value, icon, labelKey)
  static const _categories = [
    (
      _BudgetPlanSpendingCategories.venue,
      Icons.celebration,
      'budget_plans.cat_venue',
    ),
    (
      _BudgetPlanSpendingCategories.catering,
      Icons.restaurant,
      'budget_plans.cat_catering',
    ),
    (
      _BudgetPlanSpendingCategories.decor,
      Icons.local_florist,
      'budget_plans.cat_decor',
    ),
    (
      _BudgetPlanSpendingCategories.attire,
      Icons.checkroom,
      'budget_plans.cat_attire',
    ),
    (
      _BudgetPlanSpendingCategories.photography,
      Icons.camera_alt,
      'budget_plans.cat_photography',
    ),
    (
      _BudgetPlanSpendingCategories.other,
      Icons.more_horiz,
      'budget_plans.cat_other',
    ),
  ];

  const _SpendingCategoryChips({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _categories.map((c) {
        final (value, icon, labelKey) = c;
        final isSelected = selected == value;
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16),
              const SizedBox(width: 4),
              Text(labelKey.tr),
            ],
          ),
          selected: isSelected,
          onSelected: (s) => onChanged(s ? value : null),
          selectedColor: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.2),
          checkmarkColor: Theme.of(context).colorScheme.secondary,
        );
      }).toList(),
    );
  }
}

class _AttachReceiptTile extends StatelessWidget {
  final String? receiptPath;
  final String planUuid;
  final ValueChanged<String> onAttached;

  const _AttachReceiptTile({
    required this.receiptPath,
    required this.planUuid,
    required this.onAttached,
  });

  @override
  Widget build(BuildContext context) {
    final hasReceipt = receiptPath != null;

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: hasReceipt
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: hasReceipt
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasReceipt ? Icons.check_circle_outline : Icons.attach_file,
              color: hasReceipt
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              size: AppIconSize.md,
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Text(
                hasReceipt
                    ? 'budget_plans.receipt_attached_short'.tr
                    : 'budget_plans.attach_receipt'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: hasReceipt
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Icon(
              Icons.add_a_photo,
              color: Theme.of(context).colorScheme.primary,
              size: AppIconSize.md,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        onAttached(result.files.single.path!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'budget_plans.receipt_attached'.trWith({
                  'name': result.files.single.name,
                }),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'budget_plans.receipt_failed'.trWith({'error': e.toString()}),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

class _LinkTransactionToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _LinkTransactionToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'budget_plans.link_to_main'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'budget_plans.link_to_main_subtitle'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}
