import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../shared/commitment_type_helpers.dart';
import '../shared/savings_dropdown.dart';
import '../shared/payee_dropdown.dart';

/// Opens a bottom sheet for adding or editing a [CommitmentTaskVO].
///
/// Use [title] / [confirmLabel] to distinguish Add vs Edit.
/// Pass [initial] to pre-fill the form when editing.
/// [onConfirm] receives the constructed [CommitmentTaskVO] after validation.
/// [onError] receives validation error messages to show as snack bars.
///
/// Example:
/// ```dart
/// showTaskBottomSheet(
///   context: context,
///   title: 'Add Task',
///   confirmLabel: 'Add',
///   savings: savingVOList,
///   payees: payeeVOList,
///   onConfirm: (task) => bloc.add(AddCommitmentTaskEvent(task)),
///   onError: (msg) => showCommitmentSnackBar(context, message: msg, ...),
/// );
/// ```
void showTaskBottomSheet({
  required BuildContext context,
  required String title,
  required String confirmLabel,
  required List<ListSavingVO> savings,
  required List<PayeeVO> payees,
  CommitmentTaskVO? initial,
  required void Function(CommitmentTaskVO task) onConfirm,
  required void Function(String message) onError,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TaskBottomSheet(
      title: title,
      confirmLabel: confirmLabel,
      savings: savings,
      payees: payees,
      initial: initial,
      onConfirm: onConfirm,
      onError: onError,
    ),
  );
}

// ---------------------------------------------------------------------------
// Private sheet widget
// ---------------------------------------------------------------------------

class _TaskBottomSheet extends StatefulWidget {
  final String title;
  final String confirmLabel;
  final List<ListSavingVO> savings;
  final List<PayeeVO> payees;
  final CommitmentTaskVO? initial;
  final void Function(CommitmentTaskVO) onConfirm;
  final void Function(String) onError;

  const _TaskBottomSheet({
    required this.title,
    required this.confirmLabel,
    required this.savings,
    required this.payees,
    this.initial,
    required this.onConfirm,
    required this.onError,
  });

  @override
  State<_TaskBottomSheet> createState() => _TaskBottomSheetState();
}

class _TaskBottomSheetState extends State<_TaskBottomSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late final TextEditingController _referenceController;

  late CommitmentTaskType _selectedType;
  String? _selectedSourceId;
  String? _selectedTargetId;
  String? _selectedPayeeId;

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    _nameController = TextEditingController(text: i?.name ?? '');
    _amountController = TextEditingController(
      text: i?.amount != null ? i!.amount!.toStringAsFixed(2) : '',
    );
    _noteController = TextEditingController(text: i?.note ?? '');
    _referenceController = TextEditingController(
      text: i?.paymentReference ?? '',
    );
    _selectedType = i?.type ?? CommitmentTaskType.internalTransfer;
    _selectedSourceId = i?.sourceSavingId;
    _selectedTargetId = i?.targetSavingId;
    _selectedPayeeId = i?.payeeId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation + submission
  // ---------------------------------------------------------------------------

  void _submit() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty) {
      widget.onError('Please enter a task name');
      return;
    }
    if (amount == null || amount <= 0) {
      widget.onError('Please enter a valid amount');
      return;
    }
    if (_selectedType == CommitmentTaskType.internalTransfer) {
      if (_selectedSourceId == null) {
        widget.onError('Please select a source savings account');
        return;
      }
      if (_selectedTargetId == null) {
        widget.onError('Please select a target savings account');
        return;
      }
      if (_selectedSourceId == _selectedTargetId) {
        widget.onError('Source and target savings must be different');
        return;
      }
    }
    if (_selectedType == CommitmentTaskType.thirdPartyPayment) {
      if (_selectedSourceId == null) {
        widget.onError('Please select a source savings account');
        return;
      }
      if (_selectedPayeeId == null) {
        widget.onError('Please select a payee');
        return;
      }
    }

    Navigator.pop(context);

    final taskVO = (widget.initial ?? CommitmentTaskVO())
      ..name = name
      ..amount = amount
      ..type = _selectedType
      ..isDone = widget.initial?.isDone ?? false
      ..sourceSavingId = _selectedSourceId
      ..targetSavingId = _selectedTargetId
      ..payeeId = _selectedPayeeId
      ..note = _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim()
      ..paymentReference = _referenceController.text.trim().isEmpty
          ? null
          : _referenceController.text.trim();

    // Attach VO objects for immediate subtitle rendering without a reload
    if (_selectedSourceId != null) {
      taskVO.sourceSavingVO = widget.savings
          .where((s) => s.saving.id == _selectedSourceId)
          .map((s) => SavingVO.fromSvngSaving(s.saving))
          .firstOrNull;
    }
    if (_selectedTargetId != null) {
      taskVO.targetSavingVO = widget.savings
          .where((s) => s.saving.id == _selectedTargetId)
          .map((s) => SavingVO.fromSvngSaving(s.saving))
          .firstOrNull;
    }
    if (_selectedPayeeId != null) {
      taskVO.payeeVO = widget.payees
          .where((p) => p.id == _selectedPayeeId)
          .firstOrNull;
    }

    widget.onConfirm(taskVO);
  }

  // ---------------------------------------------------------------------------
  // Type-specific pickers
  // ---------------------------------------------------------------------------

  Widget _typeSpecificFields() {
    switch (_selectedType) {
      case CommitmentTaskType.internalTransfer:
        return Column(
          children: [
            const SizedBox(height: 16),
            SavingsDropdown(
              value: _selectedSourceId,
              savingVOList: widget.savings,
              label: 'Source Savings (From)',
              hint: 'commitment_tasks.select_source'.tr,
              prefixIcon: Icons.arrow_upward,
              includeNoneOption: false,
              onChanged: (v) => setState(() => _selectedSourceId = v),
            ),
            const SizedBox(height: 16),
            SavingsDropdown(
              value: _selectedTargetId,
              savingVOList: widget.savings,
              label: 'Target Savings (To)',
              hint: 'commitment_tasks.select_target'.tr,
              prefixIcon: Icons.arrow_downward,
              includeNoneOption: false,
              onChanged: (v) => setState(() => _selectedTargetId = v),
            ),
          ],
        );

      case CommitmentTaskType.thirdPartyPayment:
        return Column(
          children: [
            const SizedBox(height: 16),
            SavingsDropdown(
              value: _selectedSourceId,
              savingVOList: widget.savings,
              label: 'Source Savings (From)',
              hint: 'commitment_tasks.select_source'.tr,
              prefixIcon: Icons.arrow_upward,
              includeNoneOption: false,
              onChanged: (v) => setState(() => _selectedSourceId = v),
            ),
            const SizedBox(height: 16),
            PayeeDropdown(
              value: _selectedPayeeId,
              payeeVOList: widget.payees,
              onChanged: (v) => setState(() => _selectedPayeeId = v),
            ),
          ],
        );

      case CommitmentTaskType.cash:
        return const SizedBox.shrink();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Text(widget.title, style: AppTextStyles.h3),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Scrollable form body
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Task Name',
                      controller: _nameController,
                      hint: 'e.g., Monthly rent — March 2026',
                      prefixIcon: Icons.label_outline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Amount (RM)',
                      controller: _amountController,
                      prefixText: 'RM ',
                      keyboardType: AppTextFieldKeyboardType.decimal,
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<CommitmentTaskType>(
                      initialValue: _selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: CommitmentTaskType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(labelForTaskType(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedType = value;
                            _selectedSourceId = null;
                            _selectedTargetId = null;
                            _selectedPayeeId = null;
                          });
                        }
                      },
                    ),

                    // Type-aware pickers
                    _typeSpecificFields(),
                    const SizedBox(height: 16),

                    AppTextField(
                      label: 'Note (Optional)',
                      controller: _noteController,
                      hint: 'Any additional info',
                      maxLines: 2,
                    ),
                    if (widget.initial != null) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Payment Reference (Optional)',
                        controller: _referenceController,
                        hint: 'Receipt no., FPX ref., etc.',
                        prefixIcon: Icons.receipt_outlined,
                      ),
                    ],
                    const SizedBox(height: 24),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: AppButton.secondary(
                            label: 'general.cancel'.tr,
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppButton.primary(
                            label: widget.confirmLabel,
                            onPressed: _submit,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
