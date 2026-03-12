import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_item_entity.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_item_tag_entity.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_items_list_event.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

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

  Color get color {
    switch (this) {
      case _DepositStatus.unpaid:
        return WiseSpendsColors.error;
      case _DepositStatus.partial:
        return WiseSpendsColors.warning;
      case _DepositStatus.paid:
        return WiseSpendsColors.success;
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

  Color get color {
    switch (this) {
      case _PaymentStatus.unpaid:
        return WiseSpendsColors.error;
      case _PaymentStatus.partial:
        return WiseSpendsColors.warning;
      case _PaymentStatus.paid:
        return WiseSpendsColors.success;
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
      decoration: const BoxDecoration(
        color: WiseSpendsColors.background,
        borderRadius: BorderRadius.vertical(
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
              const _BottomSheetHandle(),
              const SizedBox(height: AppSpacing.xl),
              _SheetHeader(isEdit: _isEdit),
              const SizedBox(height: AppSpacing.xxl),

              // ── Item Details ─────────────────────────────────────────────
              _SectionLabel(label: 'budget_plans.item_details'.tr),
              const SizedBox(height: AppSpacing.md),
              _ItemDetailsCard(
                bilCtrl: _bilCtrl,
                nameCtrl: _nameCtrl,
                totalCostCtrl: _totalCostCtrl,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Deposit ──────────────────────────────────────────────────
              _SectionLabel(label: 'budget_plans.deposit'.tr),
              const SizedBox(height: AppSpacing.md),
              _DepositSection(
                hasDeposit: _hasDeposit,
                depositStatus: _depositStatus,
                depositPaidCtrl: _depositPaidCtrl,
                onToggle: _onDepositToggled,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Payment (excl. deposit) ──────────────────────────────────
              _SectionLabel(label: 'budget_plans.payment'.tr),
              const SizedBox(height: AppSpacing.md),
              _PaymentSection(
                paymentStatus: _paymentStatus,
                paidCtrl: _paidCtrl,
                totalCost: _totalCost,
                depositPaid: _depositPaid,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Total Paid summary ───────────────────────────────────────
              _TotalPaidCard(
                depositPaid: _depositPaid,
                amountPaid: _paidAmount,
                totalCost: _totalCost,
                hasDeposit: _hasDeposit,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Schedule ─────────────────────────────────────────────────
              _SectionLabel(label: 'budget_plans.schedule'.tr),
              const SizedBox(height: AppSpacing.md),
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
              const SizedBox(height: AppSpacing.xl),

              // ── Notes ────────────────────────────────────────────────────
              _SectionLabel(label: 'budget_plans.notes'.tr),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                hint: 'budget_plans.notes_hint'.tr,
                controller: _notesCtrl,
                maxLines: 3,
                prefixIcon: Icons.note_outlined,
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Tags ─────────────────────────────────────────────────────
              _SectionLabel(label: 'budget_plans.tags'.tr),
              const SizedBox(height: AppSpacing.sm),
              _TagsSection(
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

// =============================================================================
// Item Details Card
// =============================================================================

class _ItemDetailsCard extends StatelessWidget {
  final TextEditingController bilCtrl;
  final TextEditingController nameCtrl;
  final TextEditingController totalCostCtrl;

  const _ItemDetailsCard({
    required this.bilCtrl,
    required this.nameCtrl,
    required this.totalCostCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bil',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              _BilStepper(controller: bilCtrl),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: WiseSpendsColors.divider),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'budget_plans.item_name'.tr,
            hint: 'budget_plans.item_name_hint'.tr,
            controller: nameCtrl,
            prefixIcon: Icons.format_list_bulleted,
            maxLines: 2,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'error.validation.required'.tr
                : null,
          ),
          const SizedBox(height: AppSpacing.md),
          CurrencyTextField(
            label: 'budget_plans.total_cost'.tr,
            hint: '0.00',
            controller: totalCostCtrl,
            validator: (v) {
              if (v == null || v.isEmpty) return 'error.validation.required'.tr;
              final amount = double.tryParse(v);
              if (amount == null || amount <= 0) {
                return 'error.validation.invalid_amount'.tr;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Deposit Section
//
// Fields:
//   • Deposit Amount  — the agreed deposit value (e.g. RM 500)
//   • Deposit Paid    — how much of that deposit has actually been paid
//
// Status badge is AUTO-COMPUTED:
//   depositPaid == 0                      → Unpaid
//   0 < depositPaid < depositAmount       → Partial
//   depositPaid >= depositAmount          → Paid
// =============================================================================

class _DepositSection extends StatelessWidget {
  final bool hasDeposit;
  final _DepositStatus depositStatus;
  final TextEditingController depositPaidCtrl;
  final ValueChanged<bool> onToggle;

  const _DepositSection({
    required this.hasDeposit,
    required this.depositStatus,
    required this.depositPaidCtrl,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        children: [
          // ── Toggle row ────────────────────────────────────────────────────
          InkWell(
            onTap: () => onToggle(!hasDeposit),
            borderRadius: hasDeposit
                ? const BorderRadius.vertical(
                    top: Radius.circular(AppRadius.lg),
                  )
                : BorderRadius.circular(AppRadius.lg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: hasDeposit
                          ? WiseSpendsColors.primary.withValues(alpha: 0.12)
                          : WiseSpendsColors.divider.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.handshake_outlined,
                      size: 16,
                      color: hasDeposit
                          ? WiseSpendsColors.primary
                          : WiseSpendsColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'budget_plans.has_deposit'.tr,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'budget_plans.has_deposit_sub'.tr,
                          style: AppTextStyles.caption.copyWith(
                            color: WiseSpendsColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: hasDeposit,
                    onChanged: onToggle,
                    activeThumbColor: WiseSpendsColors.primary,
                  ),
                ],
              ),
            ),
          ),

          // ── Expandable fields ─────────────────────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: hasDeposit
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(height: 1, color: WiseSpendsColors.divider),
                      Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: CurrencyTextField(
                          label: 'budget_plans.deposit_paid'.tr,
                          hint: '0.00',
                          controller: depositPaidCtrl,
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Payment Section
// =============================================================================

class _PaymentSection extends StatelessWidget {
  final _PaymentStatus paymentStatus;
  final TextEditingController paidCtrl;
  final double totalCost;
  final double depositPaid;

  const _PaymentSection({
    required this.paymentStatus,
    required this.paidCtrl,
    required this.totalCost,
    required this.depositPaid,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = (totalCost - depositPaid).clamp(0.0, double.infinity);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Helper text showing the expected remaining amount
          if (totalCost > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Text(
                remaining > 0
                    ? '${'budget_plans.remaining_after_deposit'.tr}: RM ${remaining.toStringAsFixed(2)}'
                    : 'budget_plans.deposit_covers_full'.tr,
                style: AppTextStyles.caption.copyWith(
                  color: WiseSpendsColors.textSecondary,
                ),
              ),
            ),

          // Amount paid field
          CurrencyTextField(
            label: 'budget_plans.amount_paid_excl_deposit'.tr,
            hint: '0.00',
            controller: paidCtrl,
          ),
          const SizedBox(height: AppSpacing.md),

          // Auto-computed payment status
          _ComputedStatusRow(
            label: 'budget_plans.payment_status'.tr,
            status: paymentStatus,
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Computed Status Row  — read-only indicator, never a manual selector
// =============================================================================

class _ComputedStatusRow<T> extends StatelessWidget {
  final String label;
  final T status;

  const _ComputedStatusRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final String statusLabel;
    final Color statusColor;
    final IconData statusIcon;

    if (status is _DepositStatus) {
      final s = status as _DepositStatus;
      statusLabel = s.label;
      statusColor = s.color;
      statusIcon = s.icon;
    } else if (status is _PaymentStatus) {
      final s = status as _PaymentStatus;
      statusLabel = s.label;
      statusColor = s.color;
      statusIcon = s.icon;
    } else {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(statusIcon, size: 12, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: AppTextStyles.caption.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        // "auto" hint so user knows this isn't editable
        Text(
          '(auto)',
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textHint,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// Total Paid Summary Card
// =============================================================================

class _TotalPaidCard extends StatelessWidget {
  final double depositPaid;
  final double amountPaid;
  final double totalCost;
  final bool hasDeposit;

  const _TotalPaidCard({
    required this.depositPaid,
    required this.amountPaid,
    required this.totalCost,
    required this.hasDeposit,
  });

  @override
  Widget build(BuildContext context) {
    final totalPaid = depositPaid + amountPaid;
    final remaining = (totalCost - totalPaid).clamp(0.0, double.infinity);
    final progress = totalCost > 0
        ? (totalPaid / totalCost).clamp(0.0, 1.0)
        : 0.0;
    final isFullyPaid = totalCost > 0 && totalPaid >= totalCost;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isFullyPaid
            ? WiseSpendsColors.success.withValues(alpha: 0.06)
            : WiseSpendsColors.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isFullyPaid
              ? WiseSpendsColors.success.withValues(alpha: 0.3)
              : WiseSpendsColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                isFullyPaid
                    ? Icons.check_circle
                    : Icons.account_balance_wallet_outlined,
                size: 15,
                color: isFullyPaid
                    ? WiseSpendsColors.success
                    : WiseSpendsColors.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'budget_plans.total_paid_summary'.tr.toUpperCase(),
                style: AppTextStyles.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isFullyPaid
                      ? WiseSpendsColors.success
                      : WiseSpendsColors.primary,
                  letterSpacing: 0.6,
                ),
              ),
              const Spacer(),
              if (isFullyPaid)
                _StatusBadge(
                  label: 'budget_plans.fully_paid'.tr,
                  color: WiseSpendsColors.success,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Breakdown row
          Row(
            children: [
              if (hasDeposit) ...[
                Expanded(
                  child: _SummaryValue(
                    label: 'budget_plans.deposit_paid_label'.tr,
                    value: 'RM ${depositPaid.toStringAsFixed(2)}',
                    subLabel: null,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  width: 1,
                  height: 36,
                  color: WiseSpendsColors.divider,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: _SummaryValue(
                  label: 'budget_plans.payment_paid_label'.tr,
                  value: 'RM ${amountPaid.toStringAsFixed(2)}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(width: 1, height: 36, color: WiseSpendsColors.divider),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SummaryValue(
                  label: isFullyPaid
                      ? 'budget_plans.total_paid'.tr
                      : 'budget_plans.remaining'.tr,
                  value: isFullyPaid
                      ? 'RM ${totalPaid.toStringAsFixed(2)}'
                      : 'RM ${remaining.toStringAsFixed(2)}',
                  valueColor: isFullyPaid
                      ? WiseSpendsColors.success
                      : WiseSpendsColors.error,
                ),
              ),
            ],
          ),

          // Progress bar
          if (totalCost > 0) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.full),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: WiseSpendsColors.divider,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFullyPaid
                      ? WiseSpendsColors.success
                      : WiseSpendsColors.primary,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(progress * 100).toStringAsFixed(0)}% ${'budget_plans.paid'.tr}',
                  style: AppTextStyles.caption.copyWith(
                    color: WiseSpendsColors.textSecondary,
                  ),
                ),
                Text(
                  'RM ${totalCost.toStringAsFixed(2)}',
                  style: AppTextStyles.caption.copyWith(
                    color: WiseSpendsColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final String label;
  final String value;
  final String? subLabel;
  final Color? valueColor;

  const _SummaryValue({
    required this.label,
    required this.value,
    this.subLabel,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? WiseSpendsColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (subLabel != null)
          Text(
            subLabel!,
            style: AppTextStyles.caption.copyWith(
              color: WiseSpendsColors.textHint,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// =============================================================================
// Bil Stepper
// =============================================================================

class _BilStepper extends StatelessWidget {
  final TextEditingController controller;
  const _BilStepper({required this.controller});

  int get _current => int.tryParse(controller.text) ?? 1;

  void _step(int delta) {
    final next = _current + delta;
    if (next >= 1) controller.text = next.toString();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, _) => Container(
        height: 36,
        decoration: BoxDecoration(
          color: WiseSpendsColors.background,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: WiseSpendsColors.divider),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepBtn(icon: Icons.remove, onTap: () => _step(-1)),
            Container(
              width: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.symmetric(
                  vertical: BorderSide(color: WiseSpendsColors.divider),
                ),
              ),
              child: Text(
                controller.text.isEmpty ? '1' : controller.text,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: WiseSpendsColors.primary,
                ),
              ),
            ),
            _StepBtn(icon: Icons.add, onTap: () => _step(1)),
          ],
        ),
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 16, color: WiseSpendsColors.textSecondary),
        ),
      ),
    );
  }
}

// =============================================================================
// Date Field
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
    return InkWell(
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
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: WiseSpendsColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selectedDate != null
                ? WiseSpendsColors.primary.withValues(alpha: 0.4)
                : WiseSpendsColors.divider,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? WiseSpendsColors.primary.withValues(alpha: 0.1)
                    : WiseSpendsColors.divider.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                color: selectedDate != null
                    ? WiseSpendsColors.primary
                    : WiseSpendsColors.textSecondary,
                size: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.caption.copyWith(
                      color: WiseSpendsColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedDate != null
                        ? DateFormat('EEEE, MMMM d, y').format(selectedDate!)
                        : 'budget_plans.select_due_date'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: selectedDate != null
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: selectedDate != null
                          ? WiseSpendsColors.textPrimary
                          : WiseSpendsColors.textHint,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: WiseSpendsColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 12,
                    color: WiseSpendsColors.textSecondary,
                  ),
                ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: WiseSpendsColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Tags Section
// =============================================================================

class _TagsSection extends StatelessWidget {
  final Set<String> selectedTags;
  final bool showTagPicker;
  final VoidCallback onTogglePicker;
  final ValueChanged<String> onTagRemoved;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onPickerClose;

  const _TagsSection({
    required this.selectedTags,
    required this.showTagPicker,
    required this.onTogglePicker,
    required this.onTagRemoved,
    required this.onTagsChanged,
    required this.onPickerClose,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            ...selectedTags.map(
              (tag) => _TagChip(tag: tag, onRemove: () => onTagRemoved(tag)),
            ),
            GestureDetector(
              onTap: onTogglePicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: showTagPicker
                      ? WiseSpendsColors.primary.withValues(alpha: 0.1)
                      : WiseSpendsColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                  border: Border.all(
                    color: showTagPicker
                        ? WiseSpendsColors.primary
                        : WiseSpendsColors.divider,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      showTagPicker ? Icons.close : Icons.add,
                      size: 12,
                      color: showTagPicker
                          ? WiseSpendsColors.primary
                          : WiseSpendsColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      showTagPicker
                          ? 'general.close'.tr
                          : 'budget_plans.add_tags'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: showTagPicker
                            ? WiseSpendsColors.primary
                            : WiseSpendsColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (showTagPicker) ...[
          const SizedBox(height: AppSpacing.sm),
          _TagPicker(
            selectedTags: selectedTags,
            onTagsChanged: onTagsChanged,
            onClose: onPickerClose,
          ),
        ],
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  final VoidCallback onRemove;
  const _TagChip({required this.tag, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.xs,
        top: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: WiseSpendsColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: WiseSpendsColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: WiseSpendsColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: WiseSpendsColors.primary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 10,
                color: WiseSpendsColors.primary,
              ),
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
  late Set<String> _local;

  @override
  void initState() {
    super.initState();
    _local = Set.from(widget.selectedTags);
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
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: BudgetPlanItemTags.suggestions.map((tag) {
              final isSelected = _local.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _local.add(tag);
                    } else {
                      _local.remove(tag);
                    }
                  });
                  widget.onTagsChanged(_local);
                },
                selectedColor: WiseSpendsColors.primary.withValues(alpha: 0.2),
                checkmarkColor: WiseSpendsColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.md),
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
                onPressed: _addCustom,
                icon: Icons.add,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addCustom() {
    final tag = _customTagCtrl.text.trim();
    if (tag.isNotEmpty) {
      setState(() => _local.add(tag));
      widget.onTagsChanged(_local);
      _customTagCtrl.clear();
    }
  }
}

// =============================================================================
// Sheet Header
// =============================================================================

class _SheetHeader extends StatelessWidget {
  final bool isEdit;
  const _SheetHeader({required this.isEdit});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: WiseSpendsColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            isEdit ? Icons.edit_outlined : Icons.add_circle_outline,
            color: WiseSpendsColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEdit ? 'budget_plans.edit_item'.tr : 'budget_plans.add_item'.tr,
              style: AppTextStyles.h2,
            ),
            Text(
              isEdit
                  ? 'budget_plans.edit_item_sub'.tr
                  : 'budget_plans.add_item_sub'.tr,
              style: AppTextStyles.caption.copyWith(
                color: WiseSpendsColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =============================================================================
// Section Label
// =============================================================================

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption.copyWith(
            color: WiseSpendsColors.textSecondary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const Expanded(
          child: Divider(color: WiseSpendsColors.divider, thickness: 1),
        ),
      ],
    );
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
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: WiseSpendsColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
