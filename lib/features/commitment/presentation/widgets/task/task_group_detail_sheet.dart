import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/task_group_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Shows a bottom sheet for viewing and completing all tasks in a group.
///
/// Usage:
/// ```dart
/// showTaskGroupDetailSheet(context: context, group: group, onEditTask: (task) => ..., onDeleteTask: (task) => ...);
/// ```
void showTaskGroupDetailSheet({
  required BuildContext context,
  required TaskGroupVO group,
  void Function(dynamic task)? onEditTask,
  void Function(dynamic task)? onDeleteTask,
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
      child: _TaskGroupDetailSheet(
        group: group,
        onEditTask: onEditTask,
        onDeleteTask: onDeleteTask,
      ),
    ),
  );
}

class _TaskGroupDetailSheet extends StatefulWidget {
  final TaskGroupVO group;
  final void Function(dynamic task)? onEditTask;
  final void Function(dynamic task)? onDeleteTask;

  const _TaskGroupDetailSheet({
    required this.group,
    this.onEditTask,
    this.onDeleteTask,
  });

  @override
  State<_TaskGroupDetailSheet> createState() => _TaskGroupDetailSheetState();
}

class _TaskGroupDetailSheetState extends State<_TaskGroupDetailSheet> {
  bool _confirmingComplete = false;
  bool _isExpanded = true;

  TaskGroupVO get group => widget.group;

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
    // Mark all tasks in the group as complete
    context.read<CommitmentTaskBloc>().add(
      UpdateStatusCommitmentTaskListEvent(true, group.tasks),
    );
    Navigator.pop(context);
  }

  void _onTaskTap(dynamic task) {
    // Navigate to individual task detail if needed
    // For now, just expand the group
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${group.taskCount} Tasks',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${group.sourceMoneyStorageName ?? 'Unknown'} → ${group.targetName}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.tertiary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${group.taskCount} tasks',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.tertiary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 24, indent: 20, endIndent: 20),

            // ── Summary ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Total Amount:',
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 2,
                    ).format(group.totalAmount),
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Expandable task list ─────────────────────────────────────────
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: _buildTaskList(context),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),

            // ── Expand/Collapse button ───────────────────────────────────────
            if (group.tasks.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    _isExpanded
                        ? 'Show less'
                        : 'Show all ${group.tasks.length} tasks',
                  ),
                ),
              ),

            // ── Inline completion confirmation ────────────────────────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: _confirmingComplete
                  ? _ConfirmCompletePanel(
                      group: group,
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _onMarkComplete,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text('Complete All ${group.taskCount} Tasks'),
                      ),
                    ),
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

  Widget _buildTaskList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: group.tasks.asMap().entries.map((entry) {
          final index = entry.key;
          final task = entry.value;
          final isLast = index == group.tasks.length - 1;

          return Column(
            children: [
              _TaskItem(
                task: task,
                onTap: () => _onTaskTap(task),
                onEdit: widget.onEditTask != null
                    ? () => widget.onEditTask!(task)
                    : null,
                onDelete: widget.onDeleteTask != null
                    ? () => widget.onDeleteTask!(task)
                    : null,
              ),
              if (!isLast) const SizedBox(height: 8),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _TaskItem extends StatelessWidget {
  final dynamic task;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TaskItem({required this.task, required this.onTap, this.onEdit, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getIconForTaskType(task),
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name ?? 'Unnamed Task',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getSubtitle(task),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RM ${(task.amount ?? 0.0).toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontSize: 13,
                  ),
                ),
                if (onEdit != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    onPressed: onEdit,
                    tooltip: 'Edit task',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: onDelete,
                    tooltip: 'Delete task',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTaskType(dynamic task) {
    if (task.isInternalTransfer) {
      return Icons.swap_horiz;
    } else if (task.isThirdPartyPayment) {
      return Icons.send;
    } else if (task.isCash) {
      return Icons.money_off;
    }
    return Icons.help_outline;
  }

  String _getSubtitle(dynamic task) {
    if (task.type == CommitmentTaskType.internalTransfer) {
      return '${task.sourceSavingName} → ${task.targetSavingName}';
    } else if (task.type == CommitmentTaskType.thirdPartyPayment) {
      return '${task.sourceSavingName} → ${task.payeeName}';
    } else if (task.type == CommitmentTaskType.cash) {
      return 'Cash payment';
    }
    return 'Unknown task type';
  }
}

class _ConfirmCompletePanel extends StatelessWidget {
  final TaskGroupVO group;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const _ConfirmCompletePanel({
    required this.group,
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
            'This will mark all ${group.taskCount} tasks as complete and update your savings balances.',
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),

          // Impact summary
          _ImpactRow(
            icon: Icons.swap_horiz,
            label:
                '${group.sourceMoneyStorageName ?? 'Unknown'} → ${group.targetName}',
          ),
          _ImpactRow(
            icon: Icons.account_balance_wallet_outlined,
            label:
                'Total: ${NumberFormat.currency(symbol: 'RM ', decimalDigits: 2).format(group.totalAmount)}',
          ),

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
                  child: Text('Complete All'),
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
