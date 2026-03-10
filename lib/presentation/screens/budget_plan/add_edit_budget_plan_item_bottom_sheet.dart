import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_item_entity.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_item_tag_entity.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_items_list/budget_plan_items_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan_items_list/budget_plan_items_list_event.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Add/Edit Budget Plan Item Bottom Sheet
///
/// Requires [BlocProvider.value] from the parent screen — never create
/// a new BLoC instance here.
///
/// Handles the `clearNotes` and `clearDueDate` sentinels so that explicitly
/// clearing an optional field is correctly persisted (null means "no change"
/// in [UpdateBudgetPlanItem], not "clear the field").
class AddEditBudgetPlanItemBottomSheet extends StatefulWidget {
  final String planId;
  final BudgetPlanItemEntity? item;

  const AddEditBudgetPlanItemBottomSheet({
    super.key,
    required this.planId,
    this.item,
  });

  @override
  State<AddEditBudgetPlanItemBottomSheet> createState() =>
      _AddEditBudgetPlanItemBottomSheetState();
}

class _AddEditBudgetPlanItemBottomSheetState
    extends State<AddEditBudgetPlanItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bilCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _totalCostCtrl;
  late final TextEditingController _depositCtrl;
  late final TextEditingController _paidCtrl;
  late final TextEditingController _notesCtrl;

  DateTime? _selectedDueDate;
  bool _dueDateCleared = false; // sentinel: user explicitly cleared due date

  Set<String> _selectedTags = {};
  bool _showTagPicker = false;

  // Payment status helpers
  bool _hasDeposit = false;
  bool _isFullyPaid = false;
  bool _isCustomPayment = false;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _bilCtrl = TextEditingController(text: item?.bil ?? '');
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _totalCostCtrl = TextEditingController(
      text: item != null ? item.totalCost.toStringAsFixed(2) : '',
    );
    _depositCtrl = TextEditingController(
      text: item != null ? item.depositPaid.toStringAsFixed(2) : '',
    );
    _paidCtrl = TextEditingController(
      text: item != null ? item.amountPaid.toStringAsFixed(2) : '',
    );
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
    _selectedDueDate = item?.dueDate;
    _selectedTags = item?.tags.toSet() ?? {};
    
    // Initialize payment status helpers
    if (item != null) {
      _hasDeposit = item.depositPaid > 0;
      _isFullyPaid = item.isFullyPaid;
      _isCustomPayment = item.amountPaid > 0 && !item.isFullyPaid && item.depositPaid == 0;
    }
  }

  @override
  void dispose() {
    _bilCtrl.dispose();
    _nameCtrl.dispose();
    _totalCostCtrl.dispose();
    _depositCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
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

              // Title
              SectionHeader(
                title: _isEdit
                    ? 'budget_plans.edit_item'.tr
                    : 'budget_plans.add_item'.tr,
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: WiseSpendsColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    _isEdit ? Icons.edit : Icons.add,
                    color: WiseSpendsColors.primary,
                    size: AppIconSize.md,
                  ),
                ),
                showDivider: true,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Bil + Name on same row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bil (narrow field)
                  SizedBox(
                    width: 72,
                    child: AppTextField(
                      label: 'Bil',
                      hint: '1',
                      controller: _bilCtrl,
                      keyboardType: AppTextFieldKeyboardType.text,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'budget_plans.required'.tr
                          : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),

                  // Name (fills remaining width)
                  Expanded(
                    child: AppTextField(
                      label: 'budget_plans.item_name'.tr,
                      hint: 'budget_plans.item_name_hint'.tr,
                      controller: _nameCtrl,
                      prefixIcon: Icons.format_list_bulleted,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'error.validation.required'.tr
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Total Cost
              CurrencyTextField(
                label: 'budget_plans.total_cost'.tr,
                hint: '0.00',
                controller: _totalCostCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'error.validation.required'.tr;
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'error.validation.invalid_amount'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Deposit Paid + Amount Paid side by side
              Row(
                children: [
                  Expanded(
                    child: CurrencyTextField(
                      label: 'budget_plans.deposit_paid'.tr,
                      hint: '0.00',
                      controller: _depositCtrl,
                      onChanged: (_) => _updatePaymentStatusFromValues(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: CurrencyTextField(
                      label: 'budget_plans.amount_paid'.tr,
                      hint: '0.00',
                      controller: _paidCtrl,
                      onChanged: (_) => _updatePaymentStatusFromValues(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Payment Status Helpers
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: WiseSpendsColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: WiseSpendsColors.divider),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'budget_plans.payment_status'.tr,
                      style: AppTextStyles.bodySemiBold,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentStatusCheckbox(
                            label: 'budget_plans.has_deposit'.tr,
                            icon: Icons.handshake_outlined,
                            isChecked: _hasDeposit,
                            onChanged: (value) => _setHasDeposit(value),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _PaymentStatusCheckbox(
                            label: 'budget_plans.fully_paid'.tr,
                            icon: Icons.check_circle_outline,
                            isChecked: _isFullyPaid,
                            onChanged: (value) => _setFullyPaid(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _PaymentStatusCheckbox(
                            label: 'budget_plans.custom_payment'.tr,
                            icon: Icons.payment_outlined,
                            isChecked: _isCustomPayment,
                            onChanged: (value) => _setCustomPayment(value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Due Date with clear button
              _DateField(
                label: 'budget_plans.due_date'.tr,
                selectedDate: _selectedDueDate,
                onChanged: (d) => setState(() {
                  _selectedDueDate = d;
                  _dueDateCleared = false;
                }),
                onClear: _selectedDueDate != null
                    ? () => setState(() {
                        _selectedDueDate = null;
                        _dueDateCleared = true;
                      })
                    : null,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Notes with clear detection
              AppTextField(
                label: 'budget_plans.notes'.tr,
                hint: 'budget_plans.notes_hint'.tr,
                controller: _notesCtrl,
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: AppSpacing.lg),

              // Tags
              SectionHeaderCompact(title: 'budget_plans.tags'.tr),
              const SizedBox(height: AppSpacing.sm),
              if (_selectedTags.isEmpty && !_showTagPicker)
                AppButton.text(
                  label: 'budget_plans.add_tags'.tr,
                  onPressed: () => setState(() => _showTagPicker = true),
                  icon: Icons.tag,
                )
              else ...[
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    ..._selectedTags.map(
                      (tag) => _TagChip(
                        tag: tag,
                        onRemove: () =>
                            setState(() => _selectedTags.remove(tag)),
                      ),
                    ),
                    AppButton.text(
                      label: 'budget_plans.add_tags'.tr,
                      onPressed: () => setState(() => _showTagPicker = true),
                      icon: Icons.add,
                    ),
                  ],
                ),
              ],
              if (_showTagPicker) ...[
                const SizedBox(height: AppSpacing.sm),
                _TagPicker(
                  selectedTags: _selectedTags,
                  onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                  onClose: () => setState(() => _showTagPicker = false),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),

              // Submit
              AppButton.primary(
                label: _isEdit
                    ? 'budget_plans.save_changes'.tr
                    : 'budget_plans.add_item'.tr,
                icon: _isEdit ? Icons.save : Icons.add,
                onPressed: _submit,
                isFullWidth: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =============================================================================
  // Payment Status Helper Methods
  // =============================================================================

  /// Update payment status checkboxes based on current field values
  void _updatePaymentStatusFromValues() {
    final depositPaid = double.tryParse(_depositCtrl.text) ?? 0.0;
    final amountPaid = double.tryParse(_paidCtrl.text) ?? 0.0;
    final totalCost = double.tryParse(_totalCostCtrl.text) ?? 0.0;

    setState(() {
      _hasDeposit = depositPaid > 0;
      _isFullyPaid = amountPaid >= totalCost && totalCost > 0;
      _isCustomPayment = amountPaid > 0 && ! _isFullyPaid && depositPaid == 0;
    });
  }

  /// Set has deposit status
  void _setHasDeposit(bool value) {
    setState(() {
      _hasDeposit = value;
      if (value) {
        // Auto-fill deposit with 50% of total cost as suggestion
        final totalCost = double.tryParse(_totalCostCtrl.text) ?? 0.0;
        if (totalCost > 0 && _depositCtrl.text.isEmpty) {
          _depositCtrl.text = (totalCost * 0.5).toStringAsFixed(2);
        }
      } else {
        _depositCtrl.text = '0.00';
      }
      _updatePaymentStatusFromValues();
    });
  }

  /// Set fully paid status
  void _setFullyPaid(bool value) {
    setState(() {
      _isFullyPaid = value;
      if (value) {
        // Auto-fill amount paid to match total cost
        final totalCost = double.tryParse(_totalCostCtrl.text) ?? 0.0;
        _paidCtrl.text = totalCost.toStringAsFixed(2);
        // Also set deposit to match if not set
        if (_depositCtrl.text.isEmpty || double.tryParse(_depositCtrl.text) == 0) {
          _depositCtrl.text = totalCost.toStringAsFixed(2);
        }
      } else {
        _paidCtrl.text = '0.00';
      }
      _isCustomPayment = false;
      _updatePaymentStatusFromValues();
    });
  }

  /// Set custom payment status
  void _setCustomPayment(bool value) {
    setState(() {
      _isCustomPayment = value;
      if (value) {
        // Clear deposit and allow manual amount paid entry
        _depositCtrl.text = '0.00';
        _paidCtrl.text = '0.00';
        _isFullyPaid = false;
      }
      _updatePaymentStatusFromValues();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final totalCost = double.tryParse(_totalCostCtrl.text) ?? 0.0;
    final depositPaid = double.tryParse(_depositCtrl.text) ?? 0.0;
    final amountPaid = double.tryParse(_paidCtrl.text) ?? 0.0;
    final notesText = _notesCtrl.text.trim();

    if (!_isEdit) {
      context.read<BudgetPlanItemsListBloc>().add(
        CreateBudgetPlanItem(
          planId: widget.planId,
          bil: _bilCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          totalCost: totalCost,
          depositPaid: depositPaid,
          amountPaid: amountPaid,
          notes: notesText.isEmpty ? null : notesText,
          dueDate: _selectedDueDate,
          tags: _selectedTags.toList(),
        ),
      );
    } else {
      // Determine if notes was explicitly cleared by the user
      final originalNotes = widget.item!.notes;
      final notesCleared = originalNotes != null && notesText.isEmpty;

      context.read<BudgetPlanItemsListBloc>().add(
        UpdateBudgetPlanItem(
          itemId: widget.item!.id,
          bil: _bilCtrl.text.trim(),
          name: _nameCtrl.text.trim(),
          totalCost: totalCost,
          depositPaid: depositPaid,
          amountPaid: amountPaid,
          notes: notesCleared ? null : (notesText.isEmpty ? null : notesText),
          clearNotes: notesCleared,
          dueDate: _dueDateCleared ? null : _selectedDueDate,
          clearDueDate: _dueDateCleared,
          tags: _selectedTags.toList(),
        ),
      );
    }

    Navigator.pop(context);
  }
}

// =============================================================================
// Date Picker Field with optional clear button
// =============================================================================

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime?> onChanged;
  final VoidCallback? onClear;

  const _DateField({
    required this.label,
    required this.selectedDate,
    required this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
            );
            if (picked != null) onChanged(picked);
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: WiseSpendsColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: WiseSpendsColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: WiseSpendsColors.textSecondary,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Text(
                    selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(selectedDate!)
                        : 'budget_plans.select_due_date'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: selectedDate != null
                          ? WiseSpendsColors.textPrimary
                          : WiseSpendsColors.textHint,
                    ),
                  ),
                ),
                // Clear button — only shown when a date is selected
                if (onClear != null)
                  GestureDetector(
                    onTap: onClear,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: WiseSpendsColors.textSecondary,
                    ),
                  )
                else
                  const Icon(
                    Icons.chevron_right,
                    color: WiseSpendsColors.textSecondary,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Tag Chip
// =============================================================================

class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;

  const _TagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: WiseSpendsColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: WiseSpendsColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: AppSpacing.xs),
          InkWell(
            onTap: onRemove,
            child: const Icon(
              Icons.close,
              size: 14,
              color: WiseSpendsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Tag Picker
// =============================================================================

class _TagPicker extends StatefulWidget {
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onClose;

  const _TagPicker({
    required this.selectedTags,
    required this.onTagsChanged,
    required this.onClose,
  });

  @override
  State<_TagPicker> createState() => _TagPickerState();
}

class _TagPickerState extends State<_TagPicker> {
  final _customTagCtrl = TextEditingController();
  late Set<String> _localSelectedTags;

  @override
  void initState() {
    super.initState();
    _localSelectedTags = Set.from(widget.selectedTags);
  }

  @override
  void dispose() {
    _customTagCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'budget_plans.select_tags'.tr,
                style: AppTextStyles.bodySemiBold,
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  widget.onTagsChanged(_localSelectedTags);
                  widget.onClose();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Pre-defined tags
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: BudgetPlanItemTags.suggestions.map((tag) {
              final isSelected = _localSelectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) => setState(() {
                  if (selected) {
                    _localSelectedTags.add(tag);
                  } else {
                    _localSelectedTags.remove(tag);
                  }
                }),
                selectedColor: WiseSpendsColors.primary.withValues(alpha: 0.2),
                checkmarkColor: WiseSpendsColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Custom tag input
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  hint: 'budget_plans.custom_tag_hint'.tr,
                  controller: _customTagCtrl,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              AppButton.primary(
                label: 'general.add'.tr,
                onPressed: _addCustomTag,
                icon: Icons.add,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCustomTag() {
    final tag = _customTagCtrl.text.trim();
    if (tag.isNotEmpty) {
      setState(() => _localSelectedTags.add(tag));
      _customTagCtrl.clear();
    }
  }
}

// =============================================================================
// Bottom Sheet Handle
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
          color: WiseSpendsColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

// =============================================================================
// Payment Status Checkbox
// =============================================================================

class _PaymentStatusCheckbox extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const _PaymentStatusCheckbox({
    required this.label,
    required this.icon,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isChecked
              ? WiseSpendsColors.primary.withValues(alpha: 0.1)
              : WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isChecked
                ? WiseSpendsColors.primary
                : WiseSpendsColors.divider,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isChecked ? Icons.check_box : Icons.check_box_outline_blank,
              color: isChecked
                  ? WiseSpendsColors.primary
                  : WiseSpendsColors.textSecondary,
              size: 18,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        size: 14,
                        color: isChecked
                            ? WiseSpendsColors.primary
                            : WiseSpendsColors.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          label,
                          style: AppTextStyles.caption.copyWith(
                            color: isChecked
                                ? WiseSpendsColors.primary
                                : WiseSpendsColors.textSecondary,
                            fontWeight: isChecked
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
