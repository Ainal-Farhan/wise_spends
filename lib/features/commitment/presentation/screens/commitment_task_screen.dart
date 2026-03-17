import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_state.dart';
import 'package:wise_spends/features/commitment/presentation/widgets/task/task_detail_sheet.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../widgets/shared/commitment_snack_bar.dart';
import '../widgets/task/task_card.dart';
import '../widgets/task/task_filter_bar.dart';
import '../widgets/task/task_bottom_sheet.dart';

class CommitmentTaskScreen extends StatelessWidget {
  final CommitmentTaskBloc bloc;

  const CommitmentTaskScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc..add(LoadCommitmentTasksEvent()),
      child: const _CommitmentTaskScreenContent(),
    );
  }
}

class _CommitmentTaskScreenContent extends StatelessWidget {
  const _CommitmentTaskScreenContent();

  // ---------------------------------------------------------------------------
  // State helpers
  // ---------------------------------------------------------------------------

  List<ListSavingVO> _savings(BuildContext context) {
    final s = context.read<CommitmentTaskBloc>().state;
    return s is CommitmentTaskLoaded ? s.savingVOList : [];
  }

  List<PayeeVO> _payees(BuildContext context) {
    final s = context.read<CommitmentTaskBloc>().state;
    return s is CommitmentTaskLoaded ? s.payeeVOList : [];
  }

  List<CommitmentTaskVO> _filterTasks(
    List<CommitmentTaskVO> tasks,
    String status,
  ) {
    switch (status) {
      case 'pending':
        return tasks.where((t) => t.isDone != true).toList();
      case 'completed':
        return tasks.where((t) => t.isDone == true).toList();
      default:
        return tasks;
    }
  }

  // ---------------------------------------------------------------------------
  // Sheet launchers
  // ---------------------------------------------------------------------------

  void _showAddSheet(BuildContext context) {
    showTaskBottomSheet(
      context: context,
      title: 'Add Task',
      confirmLabel: 'Add',
      savings: _savings(context),
      payees: _payees(context),
      onConfirm: (task) =>
          context.read<CommitmentTaskBloc>().add(AddCommitmentTaskEvent(task)),
      onError: (msg) => _showError(context, msg),
    );
  }

  void _showEditSheet(BuildContext context, CommitmentTaskVO task) {
    showTaskBottomSheet(
      context: context,
      title: 'Edit Task',
      confirmLabel: 'Update',
      savings: _savings(context),
      payees: _payees(context),
      initial: task,
      onConfirm: (updated) => context.read<CommitmentTaskBloc>().add(
        EditCommitmentTaskEvent(updated),
      ),
      onError: (msg) => _showError(context, msg),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _confirmDelete(BuildContext context, CommitmentTaskVO task) {
    showDeleteDialog(
      context: context,
      title: 'Delete Task?',
      message:
          'Are you sure you want to delete this task? This cannot be undone.',
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      onDelete: () => context.read<CommitmentTaskBloc>().add(
        DeleteCommitmentTaskEvent(task),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showInfoDialog(
      context: context,
      title: 'About Commitment Tasks',
      message:
          'Commitment Tasks are generated when you distribute a commitment. '
          'Each task represents one payment — internal transfer between your savings, '
          'a payment to an external party, or a cash payment. '
          'Mark tasks complete to update your savings balance.',
      okText: 'Got it',
    );
  }

  void _showError(BuildContext context, String message) {
    showCommitmentSnackBar(
      context,
      message: message,
      icon: Icons.error_outline,
      color: Theme.of(context).colorScheme.error,
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('commitment_tasks.title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.home),
          onPressed: () => Navigator.of(
            context,
          ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
          tooltip: 'Home',
        ),
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
            showCommitmentSnackBar(
              context,
              message: state.message,
              icon: Icons.check_circle,
              color: Theme.of(context).colorScheme.primary,
            );
          } else if (state is CommitmentTaskError) {
            showCommitmentSnackBar(
              context,
              message: state.message,
              icon: Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommitmentTaskLoaded) {
            final filtered = _filterTasks(state.tasks, state.filterStatus);
            return RefreshIndicator(
              onRefresh: () async => context.read<CommitmentTaskBloc>().add(
                LoadCommitmentTasksEvent(),
              ),
              child: Column(
                children: [
                  const TaskFilterBar(),
                  Expanded(
                    child: filtered.isEmpty
                        ? _EmptyTaskState(filterStatus: state.filterStatus)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final task = filtered[index];
                              return CommitmentTaskCard(
                                task: task,
                                onTap: () => showTaskDetailSheet(
                                  context: context,
                                  task: task,
                                ),
                                onEdit: () => _showEditSheet(context, task),
                                onDelete: () => _confirmDelete(context, task),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          if (state is CommitmentTaskError) {
            return _ErrorTaskState(message: state.message);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private state widgets
// ---------------------------------------------------------------------------

class _EmptyTaskState extends StatelessWidget {
  final String filterStatus;
  const _EmptyTaskState({required this.filterStatus});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checklist_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text('commitment_tasks.no_tasks'.tr, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              filterStatus == 'all'
                  ? 'Tasks will appear here after you distribute a commitment'
                  : 'No $filterStatus tasks',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Refresh',
                icon: Icons.refresh,
                onPressed: () => context.read<CommitmentTaskBloc>().add(
                  LoadCommitmentTasksEvent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorTaskState extends StatelessWidget {
  final String message;
  const _ErrorTaskState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 16),
            Text(
              'commitment_tasks.something_wrong'.tr,
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Retry',
                onPressed: () => context.read<CommitmentTaskBloc>().add(
                  LoadCommitmentTasksEvent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
