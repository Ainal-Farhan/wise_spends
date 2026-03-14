import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/screens/commitment_task_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_state.dart';
import 'package:wise_spends/features/commitment/data/repositories/impl/commitment_task_repository.dart';

/// Commitment Tasks Widget for Home Screen
/// Shows pending commitment tasks count and quick access
class CommitmentTasksWidget extends StatelessWidget {
  const CommitmentTasksWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CommitmentTaskBloc(CommitmentTaskRepository())
            ..add(LoadCommitmentTasksEvent()),
      child: const _CommitmentTasksWidgetContent(),
    );
  }
}

class _CommitmentTasksWidgetContent extends StatelessWidget {
  const _CommitmentTasksWidgetContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommitmentTaskBloc, CommitmentTaskState>(
      builder: (context, state) {
        if (state is CommitmentTaskLoaded) {
          final tasks = state.tasks;
          final pendingTasks = tasks.where((t) => t.isDone != true).toList();
          final pendingCount = pendingTasks.length;

          // Don't show widget if no tasks
          if (tasks.isEmpty) {
            return const SizedBox.shrink();
          }

          return AppCard(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommitmentTaskScreen(
                    bloc: CommitmentTaskBloc(CommitmentTaskRepository()),
                  ),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: pendingCount > 0
                            ? Theme.of(
                                context,
                              ).colorScheme.tertiary.withValues(alpha: 0.2)
                            : Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        pendingCount > 0 ? Icons.schedule : Icons.check_circle,
                        color: pendingCount > 0
                            ? Theme.of(context).colorScheme.tertiary
                            : Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Commitment Tasks',
                            style: AppTextStyles.bodySemiBold,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pendingCount > 0
                                ? '$pendingCount pending'
                                : 'All caught up!',
                            style: AppTextStyles.caption.copyWith(
                              color: pendingCount > 0
                                  ? Theme.of(context).colorScheme.tertiary
                                  : Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                if (pendingCount > 0 && pendingTasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  Text(
                    'Next: ${pendingTasks.first.name ?? 'Unnamed task'}',
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${(pendingTasks.first.amount ?? 0.0).toStringAsFixed(2)}',
                    style: AppTextStyles.amountSmall.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        // Loading state - show shimmer
        return const ShimmerCard(height: 100, padding: EdgeInsets.all(16));
      },
    );
  }
}
