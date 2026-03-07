import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_task_type.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/domain/entities/impl/saving/saving_vo.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/shared/resources/ui/snack_bar/message.dart';

// ---------------------------------------------------------------------------
// CommitmentDetailForm
// ---------------------------------------------------------------------------
// Source saving is always the commitment's referredSavingId — shown read-only.
// The user only picks the destination (target saving or payee) depending on
// the payment type.
// ---------------------------------------------------------------------------

class CommitmentDetailForm extends StatefulWidget {
  final String commitmentId;
  final CommitmentDetailVO commitmentDetailVO;
  final List<ListSavingVO> savingVOList;
  final List<PayeeVO> payeeVOList;

  /// Parent commitment — used to lock the source saving display.
  final CommitmentVO? commitmentVO;

  const CommitmentDetailForm({
    required this.commitmentId,
    required this.commitmentDetailVO,
    required this.savingVOList,
    this.payeeVOList = const [],
    this.commitmentVO,
    super.key,
  });

  @override
  State<CommitmentDetailForm> createState() => _CommitmentDetailFormState();
}

class _CommitmentDetailFormState extends State<CommitmentDetailForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;

  late CommitmentTaskType _taskType;
  late CommitmentDetailType? _recurrenceType;

  String? _sourceSavingId;
  String? _sourceSavingName;
  String? _targetSavingId;
  String? _payeeId;

  @override
  void initState() {
    super.initState();
    final vo = widget.commitmentDetailVO;

    _descriptionController = TextEditingController(text: vo.description ?? '');
    _amountController = TextEditingController(
      text: vo.amount != null ? vo.amount!.toStringAsFixed(2) : '',
    );

    _taskType = vo.taskType;
    _recurrenceType = vo.type;
    _targetSavingId = vo.targetSavingId;
    _payeeId = vo.payeeId;

    // Source saving is locked to the commitment's referred saving
    _sourceSavingId =
        widget.commitmentVO?.referredSavingVO?.savingId ??
        vo.savingId ??
        vo.sourceSavingVO?.savingId;
    _sourceSavingName =
        widget.commitmentVO?.referredSavingVO?.savingName ??
        vo.sourceSavingVO?.savingName ??
        _sourceSavingId;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.commitmentDetailVO.commitmentDetailId != null;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isEdit ? Icons.edit_note_rounded : Icons.add_task_rounded,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEdit ? 'Edit Detail' : 'Add Detail',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Basic info ────────────────────────────────────────────────────
          _FormCard(
            children: [
              const _FieldLabel('Description'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _descriptionController,
                decoration: _inputDeco(
                  hint: 'e.g. Monthly electricity bill',
                  icon: Icons.description_outlined,
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              const _FieldLabel('Amount (RM)'),
              const SizedBox(height: 6),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: _inputDeco(
                  hint: '0.00',
                  icon: Icons.attach_money_rounded,
                  prefix: 'RM ',
                ),
                validator: (v) {
                  final p = double.tryParse(v ?? '');
                  if (p == null || p <= 0) return 'Enter a valid amount';
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Payment method ────────────────────────────────────────────────
          _FormCard(
            children: [
              const _FieldLabel('Payment Method'),
              const SizedBox(height: 10),
              _PaymentTypeSelector(
                selected: _taskType,
                onChanged: (t) => setState(() {
                  _taskType = t;
                  _targetSavingId = null;
                  _payeeId = null;
                }),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Source saving (read-only, hidden for cash) ─────────────────────
          if (_taskType != CommitmentTaskType.cash) ...[
            _FormCard(
              children: [
                const _FieldLabel('From (Source Account)'),
                const SizedBox(height: 6),
                _ReadOnlyField(
                  value: _sourceSavingName ?? 'Not set',
                  icon: Icons.account_balance_wallet_outlined,
                  tooltip:
                      'Source account is inherited from the commitment and cannot be changed here',
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // ── Destination field (type-specific) ─────────────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _buildDestinationField(),
          ),

          // ── Recurrence ────────────────────────────────────────────────────
          _FormCard(
            children: [
              const _FieldLabel('Recurrence'),
              const SizedBox(height: 6),
              DropdownButtonFormField<CommitmentDetailType>(
                initialValue: _recurrenceType,
                decoration: _inputDeco(
                  hint: 'Select recurrence',
                  icon: Icons.repeat_rounded,
                ),
                items: CommitmentDetailType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(_recurrenceLabel(t)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _recurrenceType = v),
                validator: (v) => v == null ? 'Select a recurrence' : null,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Save ──────────────────────────────────────────────────────────
          FilledButton.icon(
            onPressed: _onSave,
            icon: const Icon(Icons.save_rounded),
            label: Text(isEdit ? 'Update Detail' : 'Save Detail'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Destination field
  // ---------------------------------------------------------------------------

  Widget _buildDestinationField() {
    switch (_taskType) {
      case CommitmentTaskType.internalTransfer:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FormCard(
            headerIcon: Icons.swap_horiz_rounded,
            headerLabel: 'Transfer Destination',
            headerColor: Colors.blue,
            children: [
              const _FieldLabel('To (Target Account)'),
              const SizedBox(height: 6),
              _SavingDropdown(
                value: _targetSavingId,
                savings: widget.savingVOList,
                hint: 'Select target account',
                leadingIcon: Icons.arrow_downward_rounded,
                excludeId: _sourceSavingId,
                onChanged: (v) => setState(() => _targetSavingId = v),
                validator: (v) => v == null ? 'Select a target account' : null,
              ),
            ],
          ),
        );

      case CommitmentTaskType.thirdPartyPayment:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FormCard(
            headerIcon: Icons.send_rounded,
            headerLabel: 'Payment Recipient',
            headerColor: Colors.orange,
            children: [
              const _FieldLabel('Payee'),
              const SizedBox(height: 6),
              widget.payeeVOList.isEmpty
                  ? _EmptyPayeeHint()
                  : DropdownButtonFormField<String>(
                      initialValue: _payeeId,
                      decoration: _inputDeco(
                        hint: 'Select payee',
                        icon: Icons.person_outline_rounded,
                      ),
                      items: widget.payeeVOList
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    p.name ?? 'Unnamed Payee',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (p.bankName != null ||
                                      p.accountNumber != null)
                                    Text(
                                      [
                                        p.bankName,
                                        p.accountNumber,
                                      ].where((s) => s != null).join(' • '),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                      selectedItemBuilder: (_) => widget.payeeVOList
                          .map((p) => Text(p.name ?? 'Unnamed Payee'))
                          .toList(),
                      onChanged: (v) => setState(() => _payeeId = v),
                      validator: (v) => v == null ? 'Select a payee' : null,
                    ),
            ],
          ),
        );

      case CommitmentTaskType.cash:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _FormCard(
            headerIcon: Icons.payments_outlined,
            headerLabel: 'Cash Payment',
            headerColor: Colors.green,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: Colors.green[700],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No savings account will be affected when this task is completed.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  void _onSave() {
    if (!_formKey.currentState!.validate()) {
      showSnackBarMessage(context, 'Please fix the errors above');
      return;
    }

    if (_taskType == CommitmentTaskType.internalTransfer &&
        _sourceSavingId != null &&
        _sourceSavingId == _targetSavingId) {
      showSnackBarMessage(
        context,
        'Source and target accounts must be different',
      );
      return;
    }

    final vo = widget.commitmentDetailVO
      ..description = _descriptionController.text.trim()
      ..amount = double.parse(_amountController.text.trim())
      ..taskType = _taskType
      ..type = _recurrenceType
      ..savingId = _taskType == CommitmentTaskType.cash ? null : _sourceSavingId
      ..targetSavingId = _taskType == CommitmentTaskType.internalTransfer
          ? _targetSavingId
          : null
      ..payeeId = _taskType == CommitmentTaskType.thirdPartyPayment
          ? _payeeId
          : null;

    // Attach VOs for immediate UI update
    if (_sourceSavingId != null) {
      final match = widget.savingVOList
          .where((s) => s.saving.id == _sourceSavingId)
          .firstOrNull;
      if (match != null) {
        vo.sourceSavingVO = SavingVO.fromSvngSaving(match.saving);
      }
    }
    if (_targetSavingId != null) {
      final match = widget.savingVOList
          .where((s) => s.saving.id == _targetSavingId)
          .firstOrNull;
      if (match != null) {
        vo.targetSavingVO = SavingVO.fromSvngSaving(match.saving);
      }
    }
    if (_payeeId != null) {
      vo.payeeVO = widget.payeeVOList
          .where((p) => p.id == _payeeId)
          .firstOrNull;
    }

    BlocProvider.of<CommitmentBloc>(context).add(
      SaveCommitmentDetailEvent(
        commitmentDetailVO: vo,
        commitmentId: widget.commitmentId,
      ),
    );

    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    String? prefix,
  }) => InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, size: 20),
    prefixText: prefix,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    filled: true,
    fillColor: Colors.grey.shade50,
  );

  String _recurrenceLabel(CommitmentDetailType t) {
    switch (t) {
      case CommitmentDetailType.monthly:
        return 'Monthly';
      case CommitmentDetailType.weekly:
        return 'Weekly';
      case CommitmentDetailType.quarterly:
        return 'Quarterly';
      case CommitmentDetailType.yearly:
        return 'Yearly';
      case CommitmentDetailType.oneOff:
        return 'One-off';
    }
  }
}

// ===========================================================================
// Sub-widgets
// ===========================================================================

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  final IconData? headerIcon;
  final String? headerLabel;
  final Color? headerColor;

  const _FormCard({
    required this.children,
    this.headerIcon,
    this.headerLabel,
    this.headerColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerIcon != null && headerLabel != null) ...[
            Row(
              children: [
                Icon(headerIcon, size: 16, color: headerColor),
                const SizedBox(width: 6),
                Text(
                  headerLabel!,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: headerColor,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Divider(height: 1, color: Colors.grey.shade200),
            const SizedBox(height: 12),
          ],
          ...children,
        ],
      ),
    );
  }
}

/// Grey locked field for read-only source saving display.
class _ReadOnlyField extends StatelessWidget {
  final String value;
  final IconData icon;
  final String? tooltip;

  const _ReadOnlyField({required this.value, required this.icon, this.tooltip});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[500]),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}

class _PaymentTypeSelector extends StatelessWidget {
  final CommitmentTaskType selected;
  final ValueChanged<CommitmentTaskType> onChanged;

  const _PaymentTypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: CommitmentTaskType.values.map((type) {
        final isSelected = type == selected;
        final color = _colorForType(type);
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Material(
              color: isSelected
                  ? color.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onChanged(type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? color : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        _iconForType(type),
                        size: 22,
                        color: isSelected ? color : Colors.grey[400],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _shortLabel(type),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected ? color : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _iconForType(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return Icons.swap_horiz_rounded;
      case CommitmentTaskType.thirdPartyPayment:
        return Icons.send_rounded;
      case CommitmentTaskType.cash:
        return Icons.payments_outlined;
    }
  }

  Color _colorForType(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return Colors.blue;
      case CommitmentTaskType.thirdPartyPayment:
        return Colors.orange;
      case CommitmentTaskType.cash:
        return Colors.green;
    }
  }

  String _shortLabel(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return 'Transfer';
      case CommitmentTaskType.thirdPartyPayment:
        return 'Pay Out';
      case CommitmentTaskType.cash:
        return 'Cash';
    }
  }
}

class _SavingDropdown extends StatelessWidget {
  final String? value;
  final List<ListSavingVO> savings;
  final String hint;
  final IconData leadingIcon;
  final String? excludeId;
  final ValueChanged<String?> onChanged;
  final FormFieldValidator<String?>? validator;

  const _SavingDropdown({
    required this.value,
    required this.savings,
    required this.hint,
    required this.leadingIcon,
    required this.onChanged,
    this.excludeId,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = savings.where((s) => s.saving.id != excludeId).toList();
    return DropdownButtonFormField<String>(
      initialValue: filtered.any((s) => s.saving.id == value) ? value : null,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(leadingIcon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      items: filtered
          .map(
            (s) => DropdownMenuItem(
              value: s.saving.id,
              child: Text(s.saving.name ?? 'Unnamed'),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}

class _EmptyPayeeHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.orange[700],
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No payees found. Add a payee first in the Payee Management screen.',
              style: TextStyle(fontSize: 13, color: Colors.orange[800]),
            ),
          ),
        ],
      ),
    );
  }
}
