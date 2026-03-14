import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_item_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_item_widgets.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_date_field.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_tags_widgets.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_item_details.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_payment_widgets.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/budget_plan_total_paid_card.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

/// Add/Edit Budget Plan Item Bottom Sheet
///
/// Pass [nextBilNumber] to enable auto-increment for new items.
/// Requires [BlocProvider.value] from the parent screen.
class AddEditBudgetPlanItemBottomSheet extends StatefulWidget {
  final String planId;
  final BudgetPlanItemEntity? item;
  final int? nextBilNumber;

  const AddEditBudgetPlanItemBottomSheet({
    super.key,
    required this.planId,
    this.item,
    this.nextBilNumber,
  });

  @override
  State<AddEditBudgetPlanItemBottomSheet> createState() =>
      _AddEditBudgetPlanItemBottomSheetState();
}

// ---------------------------------------------------------------------------
// Status enums — display only, always computed never manually set
// ---------------------------------------------------------------------------

enum _DepositStatus { unpaid, partial, paid }

extension _DepositStatusX on _DepositStatus {
  String get label {
    switch (this) {
      case _DepositStatus.unpaid:
        return 'Unpaid';
      case _DepositStatus.partial:
        return 'Partial';
      case _DepositStatus.paid:
        return 'Paid';
    }
  }

  IconData get icon {
    switch (this) {
      case _DepositStatus.unpaid:
        return Icons.radio_button_unchecked;
      case _DepositStatus.partial:
        return Icons.pie_chart_outline;
      case _DepositStatus.paid:
        return Icons.check_circle_outline;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case _DepositStatus.unpaid:
        return Theme.of(context).colorScheme.error;
      case _DepositStatus.partial:
        return Theme.of(context).colorScheme.tertiary;
      case _DepositStatus.paid:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

enum _PaymentStatus { unpaid, partial, paid }

extension _PaymentStatusX on _PaymentStatus {
  String get label {
    switch (this) {
      case _PaymentStatus.unpaid:
        return 'Unpaid';
      case _PaymentStatus.partial:
        return 'Partial';
      case _PaymentStatus.paid:
        return 'Paid';
    }
  }

  IconData get icon {
    switch (this) {
      case _PaymentStatus.unpaid:
        return Icons.radio_button_unchecked;
      case _PaymentStatus.partial:
        return Icons.pie_chart_outline;
      case _PaymentStatus.paid:
        return Icons.check_circle_outline;
    }
  }

  Color getColor(BuildContext context) {
    switch (this) {
      case _PaymentStatus.unpaid:
        return Theme.of(context).colorScheme.error;
      case _PaymentStatus.partial:
        return Theme.of(context).colorScheme.tertiary;
      case _PaymentStatus.paid:
        return Theme.of(context).colorScheme.primary;
    }
  }
}

// ---------------------------------------------------------------------------

class _AddEditBudgetPlanItemBottomSheetState
    extends State<AddEditBudgetPlanItemBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _bilCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _totalCostCtrl;

  late final TextEditingController _depositPaidCtrl;

  // Payment: amount paid toward the item (excluding deposit)
  late final TextEditingController _paidCtrl;

  late final TextEditingController _notesCtrl;

  DateTime? _selectedDueDate;
  bool _dueDateCleared = false;
  Set<String> _selectedTags = {};
  bool _showTagPicker = false;

  bool _hasDeposit = false;

  bool get _isEdit => widget.item != null;

  // ---------------------------------------------------------------------------
  // Computed values
  // ---------------------------------------------------------------------------

  double get _totalCost => double.tryParse(_totalCostCtrl.text) ?? 0.0;
  double get _depositPaid => double.tryParse(_depositPaidCtrl.text) ?? 0.0;
  double get _paidAmount => double.tryParse(_paidCtrl.text) ?? 0.0;

  /// Deposit status — derived from depositPaid vs depositAmount
  _DepositStatus get _depositStatus {
    if (_depositPaid <= 0) return _DepositStatus.unpaid;
    return _DepositStatus.paid;
  }

  /// Payment status — derived from paidAmount vs (totalCost - depositAmount)
  _PaymentStatus get _paymentStatus {
    final remaining = (_totalCost - _depositPaid).clamp(0.0, double.infinity);
    if (_paidAmount <= 0) return _PaymentStatus.unpaid;
    if (remaining > 0 && _paidAmount >= remaining) return _PaymentStatus.paid;
    return _PaymentStatus.partial;
  }

  @override
  void initState() {
    super.initState();

    final item = widget.item;
    final bilDefault =
        item?.bil ??
        (widget.nextBilNumber != null ? widget.nextBilNumber.toString() : '');

    _bilCtrl = TextEditingController(text: bilDefault);
    _nameCtrl = TextEditingController(text: item?.name ?? '');
    _totalCostCtrl = TextEditingController(
      text: item != null ? item.totalCost.toStringAsFixed(2) : '',
    );

    // On load, treat existing depositPaid as fully settled (backward compat).
    _depositPaidCtrl = TextEditingController(
      text: item != null && item.depositPaid > 0
          ? item.depositPaid.toStringAsFixed(2)
          : '',
    );
    _paidCtrl = TextEditingController(
      text: item != null && item.amountPaid > 0
          ? item.amountPaid.toStringAsFixed(2)
          : '',
    );
    _notesCtrl = TextEditingController(text: item?.notes ?? '');
    _selectedDueDate = item?.dueDate;
    _selectedTags = item?.tags.toSet() ?? {};
    _hasDeposit = item != null && item.depositPaid > 0;

    // Rebuild on any amount change so statuses & summary stay live
    for (final c in [_totalCostCtrl, _depositPaidCtrl, _paidCtrl]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _bilCtrl.dispose();
    _nameCtrl.dispose();
    _totalCostCtrl.dispose();
    _depositPaidCtrl.dispose();
    _paidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _onDepositToggled(bool value) {
    setState(() {
      _hasDeposit = value;
      if (!value) {
        _depositPaidCtrl.text = '';
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),
              SheetHeader(
                title: _isEdit
                    ? 'budget_plans.edit_item'.tr
                    : 'budget_plans.add_item'.tr,
                subtitle: 'budget_plans.item_subtitle'.tr,
                icon: _isEdit ? Icons.edit_note : Icons.add_task,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Item Details ─────────────────────────────────────────────
              SectionLabel(label: 'budget_plans.item_details'.tr),
              const SizedBox(height: AppSpacing.md),
              ItemDetailsCard(
                bilCtrl: _bilCtrl,
                nameCtrl: _nameCtrl,
                totalCostCtrl: _totalCostCtrl,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Deposit ──────────────────────────────────────────────────
              SectionLabel(label: 'budget_plans.deposit'.tr),
              const SizedBox(height: AppSpacing.md),
              DepositSection(
                hasDeposit: _hasDeposit,
                depositStatus: _depositStatus.label,
                depositStatusColor: _depositStatus.getColor(context),
                depositStatusIcon: _depositStatus.icon,
                depositPaidCtrl: _depositPaidCtrl,
                onToggle: _onDepositToggled,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Payment (excl. deposit) ──────────────────────────────────
              SectionLabel(label: 'budget_plans.payment'.tr),
              const SizedBox(height: AppSpacing.md),
              PaymentSection(
                paymentStatus: _paymentStatus.label,
                paymentStatusColor: _paymentStatus.getColor(context),
                paymentStatusIcon: _paymentStatus.icon,
                paidCtrl: _paidCtrl,
                totalCost: _totalCost,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Total Paid summary ───────────────────────────────────────
              TotalPaidCard(
                depositPaid: _depositPaid,
                amountPaid: _paidAmount,
                totalCost: _totalCost,
                hasDeposit: _hasDeposit,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Schedule ─────────────────────────────────────────────────
              SectionLabel(label: 'budget_plans.schedule'.tr),
              const SizedBox(height: AppSpacing.md),
              BudgetPlanDateField(
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
              const SizedBox(height: AppSpacing.xl),

              // ── Notes ────────────────────────────────────────────────────
              SectionLabel(label: 'budget_plans.notes'.tr),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: 'budget_plans.notes_hint'.tr,
                controller: _notesCtrl,
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Tags ─────────────────────────────────────────────────────
              SectionLabel(label: 'budget_plans.tags'.tr),
              const SizedBox(height: AppSpacing.sm),
              BudgetPlanTagsSection(
                selectedTags: _selectedTags,
                showTagPicker: _showTagPicker,
                onTogglePicker: () =>
                    setState(() => _showTagPicker = !_showTagPicker),
                onTagRemoved: (t) => setState(() => _selectedTags.remove(t)),
                onTagsChanged: (tags) => setState(() => _selectedTags = tags),
                onPickerClose: () => setState(() => _showTagPicker = false),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AppButton.primary(
                label: _isEdit
                    ? 'budget_plans.save_changes'.tr
                    : 'budget_plans.add_item'.tr,
                icon: _isEdit ? Icons.save_outlined : Icons.add,
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

    final totalCost = _totalCost;
    final depositPaid = _hasDeposit ? _depositPaid : 0.0;
    final amountPaid = _paidAmount;
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
