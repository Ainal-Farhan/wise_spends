import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import '../shared/commitment_type_helpers.dart';
import '../shared/detail_row.dart';

/// Shows a bottom sheet combining task details + inline complete confirmation.
///
/// Usage:
/// ```dart
/// showTaskDetailSheet(context: context, task: task);
/// ```
void showTaskDetailSheet({
  required BuildContext context,
  required CommitmentTaskVO task,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => BlocProvider.value(
      value: context.read<CommitmentTaskBloc>(),
      child: _TaskDetailSheet(task: task),
    ),
  );
}

class _TaskDetailSheet extends StatefulWidget {
  final CommitmentTaskVO task;

  const _TaskDetailSheet({required this.task});

  @override
  State<_TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<_TaskDetailSheet> {
  /// Flips to true when the user taps "Mark as Complete", revealing the
  /// inline confirmation section without dismissing the sheet.
  bool _confirmingComplete = false;

  CommitmentTaskVO get task => widget.task;
  bool get isDone => task.isDone == true;

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _onMarkComplete() {
    setState(() => _confirmingComplete = true);
  }

  void _onCancelComplete() {
    setState(() => _confirmingComplete = false);
  }

  void _onConfirmComplete() {
    context.read<CommitmentTaskBloc>().add(
      UpdateStatusCommitmentTaskEvent(true, task),
    );
    Navigator.pop(context);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      task.name ?? 'Unnamed Task',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _StatusChip(isDone: isDone),
                ],
              ),
            ),

            const Divider(height: 24, indent: 20, endIndent: 20),

            // ── Detail rows ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  DetailRow(
                    label: 'Amount',
                    value: NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 2,
                    ).format(task.amount ?? 0.0),
                  ),
                  DetailRow(label: 'Type', value: labelForTaskType(task.type)),
                  if (task.type == CommitmentTaskType.internalTransfer) ...[
                    DetailRow(label: 'From', value: task.sourceSavingName),
                    DetailRow(label: 'To', value: task.targetSavingName),
                  ] else if (task.type ==
                      CommitmentTaskType.thirdPartyPayment) ...[
                    DetailRow(label: 'From', value: task.sourceSavingName),
                    DetailRow(label: 'Payee', value: task.payeeName),
                    if (task.payeeVO?.bankName != null)
                      DetailRow(label: 'Bank', value: task.payeeVO!.bankName!),
                    if (task.payeeVO?.accountNumber != null)
                      DetailRow(
                        label: 'Account',
                        value: task.payeeVO!.accountNumber!,
                      ),
                  ] else if (task.type == CommitmentTaskType.cash) ...[
                    const DetailRow(label: 'Method', value: 'Cash'),
                  ],
                  if (task.note?.isNotEmpty == true)
                    DetailRow(label: 'Note', value: task.note),
                  if (task.paymentReference?.isNotEmpty == true)
                    DetailRow(label: 'Reference', value: task.paymentReference),
                ],
              ),
            ),

            // ── Inline completion confirmation ────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _confirmingComplete
                  ? _ConfirmCompletePanel(
                      task: task,
                      onCancel: _onCancelComplete,
                      onConfirm: _onConfirmComplete,
                    )
                  : const SizedBox.shrink(),
            ),

            // ── Bottom actions ────────────────────────────────────────────────
            if (!_confirmingComplete)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('general.close'.tr),
                      ),
                    ),
                    if (!isDone) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _onMarkComplete,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text('commitment_tasks.mark_complete'.tr),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // Extra bottom padding when confirmation panel is visible
            if (_confirmingComplete) const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

/// Small pill chip showing Completed / Pending status.
class _StatusChip extends StatelessWidget {
  final bool isDone;
  const _StatusChip({required this.isDone});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = isDone ? Colors.green : colorScheme.tertiary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        isDone ? 'Completed' : 'Pending',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

/// Inline panel that appears inside the sheet when the user taps
/// "Mark as Complete". Shows a brief impact summary + confirm/cancel buttons.
class _ConfirmCompletePanel extends StatelessWidget {
  final CommitmentTaskVO task;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmCompletePanel({
    required this.task,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Confirm Completion',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This will update your savings balance.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          // Impact summary
          if (task.type == CommitmentTaskType.internalTransfer) ...[
            _ImpactRow(
              icon: Icons.swap_horiz,
              label: '${task.sourceSavingName} → ${task.targetSavingName}',
            ),
          ] else if (task.type == CommitmentTaskType.thirdPartyPayment) ...[
            _ImpactRow(
              icon: Icons.send,
              label: '${task.sourceSavingName} → ${task.payeeName}',
            ),
          ] else if (task.type == CommitmentTaskType.cash) ...[
            const _ImpactRow(
              icon: Icons.money_off,
              label: 'Cash — no account affected',
            ),
          ],

          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  child: Text('general.cancel'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: onConfirm,
                  child: Text('commitment_tasks.mark_complete'.tr),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImpactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _ImpactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
