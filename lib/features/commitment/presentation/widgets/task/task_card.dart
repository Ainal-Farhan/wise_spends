import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../shared/commitment_type_helpers.dart';

/// A list card representing a single [CommitmentTaskVO].
///
/// Callbacks let the parent screen handle navigation/dialogs without
/// this widget needing any BLoC dependency.
///
/// Example:
/// ```dart
/// CommitmentTaskCard(
///   task: task,
///   onTap: () => _showDetail(task),
///   onEdit: () => _showEdit(task),
///   onComplete: () => _confirmComplete(task),
///   onDelete: () => _confirmDelete(task),
/// )
/// ```
class CommitmentTaskCard extends StatelessWidget {
  final CommitmentTaskVO task;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommitmentTaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDone = task.isDone == true;
    final accentColor = isDone
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.tertiary;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          // Status bar
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Type icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconForTaskType(task.type),
              color: accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Text block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.name ?? 'Unnamed Task',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone
                        ? Theme.of(context).colorScheme.onSurfaceVariant
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'RM ${(task.amount ?? 0.0).toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: accentColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleForTask(task),
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (isDone) SizedBox(height: 2),
                if (isDone)
                  Text(
                    _formatDateForDisplay(task.updatedDate),
                    style: AppTextStyles.caption.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // Overflow menu
          PopupMenuButton<_TaskAction>(
            icon: Icon(
              Icons.more_vert,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onSelected: (action) {
              switch (action) {
                case _TaskAction.edit:
                  onEdit();
                case _TaskAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => [
              if (!isDone)
                PopupMenuItem(
                  value: _TaskAction.edit,
                  child: _MenuRow(
                    icon: Icons.edit,
                    label: 'commitment_tasks.edit'.tr,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: _MenuRow(
                  icon: Icons.delete_outline,
                  label: 'general.delete'.tr,
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatDateForDisplay(DateTime? dateTime) {
  if (dateTime == null) {
    return '-';
  }

  try {
    final time = DateFormat('h:mm a').format(dateTime);

    return '${DateFormat('EEEE, MMMM d, yyyy').format(dateTime)}, $time';
  } catch (_) {
    return "-";
  }
}

enum _TaskAction { edit, delete }

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MenuRow({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: color)),
      ],
    );
  }
}
