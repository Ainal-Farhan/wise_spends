import 'package:flutter/material.dart';
import 'package:wise_spends/features/commitment/domain/entities/task_group_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A list card representing a group of [CommitmentTaskVO]s that share
/// the same target saving's money storage (bank/account).
///
/// This allows users to see grouped tasks at a glance and complete
/// multiple tasks in one go for easier manual transaction tracking.
class TaskGroupCard extends StatelessWidget {
  final TaskGroupVO group;
  final VoidCallback onTap;
  final VoidCallback onExpand;
  final VoidCallback? onDelete;

  const TaskGroupCard({
    super.key,
    required this.group,
    required this.onTap,
    required this.onExpand,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.secondary;

    return AppCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
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

              // Group icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.folder_open, color: accentColor, size: 24),
              ),
              const SizedBox(width: 16),

              // Text block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${group.taskCount} Tasks',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${group.sourceMoneyStorageName ?? 'Unknown'} → ${group.targetName}',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Amount and expand button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RM ${group.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: accentColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.expand_more,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        onPressed: onExpand,
                        tooltip: 'Expand group',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Preview of first few tasks
          if (group.tasks.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 8),
            ...group.tasks.take(2).map((task) {
              final isLast =
                  task == group.tasks.last ||
                  (group.tasks.take(2).last == task && group.tasks.length > 2);
              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 6),
                child: Row(
                  children: [
                    Icon(
                      _getIconForTaskType(task),
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        task.name ?? 'Unnamed Task',
                        style: AppTextStyles.caption.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'RM ${(task.amount ?? 0.0).toStringAsFixed(2)}',
                      style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (group.tasks.length > 2) ...[
              const SizedBox(height: 4),
              Text(
                '+${group.tasks.length - 2} more task${group.tasks.length > 3 ? 's' : ''}',
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ],
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
}
