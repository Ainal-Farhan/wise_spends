import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_event.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_state.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_task_vo.dart';

/// Enhanced Commitment Task Screen - Pure BLoC
class CommitmentTaskScreen extends StatelessWidget {
  final CommitmentTaskBloc bloc;

  const CommitmentTaskScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc..add(LoadCommitmentTasksEvent()),
      child: const _CommitmentTaskScreenContent(),
    );
  }
}

class _CommitmentTaskScreenContent extends StatelessWidget {
  const _CommitmentTaskScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commitment Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocConsumer<CommitmentTaskBloc, CommitmentTaskState>(
        listener: (context, state) {
          if (state is CommitmentTaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is CommitmentTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(state.message),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommitmentTaskLoaded) {
            final tasks = state.tasks;
            final filterStatus = state.filterStatus;
            final filteredTasks = _filterTasks(tasks, filterStatus);

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommitmentTaskBloc>().add(
                  LoadCommitmentTasksEvent(),
                );
              },
              child: Column(
                children: [
                  // Filter Chips
                  _buildFilterChips(),

                  // Task List
                  Expanded(
                    child: filteredTasks.isEmpty
                        ? _buildEmptyState(context, filterStatus)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredTasks.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = filteredTasks[index];
                              return _buildTaskCard(context, task);
                            },
                          ),
                  ),
                ],
              ),
            );
          } else if (state is CommitmentTaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(height: 16),
                  Text('Oops! Something went wrong', style: AppTextStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 200,
                    child: AppButton.primary(
                      label: 'Retry',
                      onPressed: () {
                        context.read<CommitmentTaskBloc>().add(
                          LoadCommitmentTasksEvent(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', Icons.all_inclusive),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', Icons.schedule),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', Icons.check_circle),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return BlocBuilder<CommitmentTaskBloc, CommitmentTaskState>(
      builder: (context, state) {
        String filterStatus = 'all';
        if (state is CommitmentTaskLoaded) {
          filterStatus = state.filterStatus;
        }

        final isSelected = filterStatus == label.toLowerCase();

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            context.read<CommitmentTaskBloc>().add(
              FilterCommitmentTasksEvent(
                selected ? label.toLowerCase() : 'all',
              ),
            );
          },
          selectedColor: AppColors.tertiary,
          checkmarkColor: Colors.white,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        );
      },
    );
  }

  List<CommitmentTaskVO> _filterTasks(
    List<CommitmentTaskVO> tasks,
    String filterStatus,
  ) {
    switch (filterStatus) {
      case 'pending':
        return tasks.where((t) => t.isDone != true).toList();
      case 'completed':
        return tasks.where((t) => t.isDone == true).toList();
      case 'all':
      default:
        return tasks;
    }
  }

  Widget _buildEmptyState(BuildContext context, String filterStatus) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No tasks found', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              filterStatus == 'all'
                  ? 'Your commitment tasks will appear here'
                  : 'No $filterStatus tasks',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Refresh',
                icon: Icons.refresh,
                onPressed: () {
                  context.read<CommitmentTaskBloc>().add(
                    LoadCommitmentTasksEvent(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, CommitmentTaskVO task) {
    final isDone = task.isDone == true;

    return AppCard(
      onTap: () => _showTaskDetailDialog(context, task),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: isDone ? AppColors.success : AppColors.warning,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),

          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDone ? Icons.check_circle : Icons.schedule,
              color: isDone ? AppColors.success : AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Task Info
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
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${(task.amount ?? 0.0).toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: isDone ? AppColors.success : AppColors.tertiary,
                    fontSize: 14,
                  ),
                ),
                if (task.referredSavingVO?.savingName != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    task.referredSavingVO!.savingName!,
                    style: AppTextStyles.caption.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'complete') {
                _confirmCompleteTask(context, task);
              } else if (value == 'remove') {
                _confirmRemoveTask(context, task);
              }
            },
            itemBuilder: (context) => [
              if (!isDone)
                const PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.success,
                      ),
                      SizedBox(width: 8),
                      Text('Mark Complete'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.cancel, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Remove',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaskDetailDialog(BuildContext context, CommitmentTaskVO task) {
    final amount = task.amount ?? 0.0;
    final isDone = task.isDone == true;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          task.name ?? 'Unnamed Task',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
              'Amount:',
              NumberFormat.currency(
                symbol: 'RM ',
                decimalDigits: 2,
              ).format(amount),
            ),
            _buildDetailRow('Status:', isDone ? 'Completed' : 'Pending'),
            if (task.referredSavingVO?.savingName != null)
              _buildDetailRow('Savings:', task.referredSavingVO!.savingName!),
            if (task.moneyStorage?.shortName != null)
              _buildDetailRow('Money Storage:', task.moneyStorage!.shortName),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          if (!isDone)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _confirmCompleteTask(context, task);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
              ),
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCompleteTask(BuildContext context, CommitmentTaskVO task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Complete Task?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Mark this task as completed? This will record the payment.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CommitmentTaskBloc>().add(
                UpdateStatusCommitmentTaskEvent(true, task),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveTask(BuildContext context, CommitmentTaskVO task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Remove Task?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Remove this task without marking it as completed?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<CommitmentTaskBloc>().add(
                UpdateStatusCommitmentTaskEvent(false, task),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'About Commitment Tasks',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Commitment Tasks are recurring payment obligations linked to your savings goals. Complete tasks to track your payments and stay on top of your financial commitments.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
