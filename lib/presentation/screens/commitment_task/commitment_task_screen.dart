import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_event.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_state.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/vo/impl/commitment/commitment_task_vo.dart';

class CommitmentTaskScreen extends StatelessWidget {
  final CommitmentTaskBloc bloc;

  const CommitmentTaskScreen({super.key, required this.bloc});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => bloc..add(LoadCommitmentTasksEvent()),
      child: BlocConsumer<CommitmentTaskBloc, CommitmentTaskState>(
        listener: (context, state) {
          if (state is CommitmentTaskUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CommitmentTaskError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentTaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommitmentTaskLoaded) {
            return _buildTaskList(state.tasks);
          } else if (state is CommitmentTaskError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CommitmentTaskBloc>().add(
                        LoadCommitmentTasksEvent(),
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading commitment tasks...'),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildTaskList(List<CommitmentTaskVO> tasks) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Text(
              'Your Commitment Tasks',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: tasks.isNotEmpty
                ? ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildTaskCard(context, task);
                    },
                  )
                : Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.checklist_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16.0),
                          const Text(
                            'No tasks yet',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          const Text(
                            'Your commitment tasks will appear here',
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, CommitmentTaskVO task) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).primaryColor.withValues(alpha: 0.1),
              Theme.of(context).primaryColor.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: ExpansionTile(
          title: Text(
            task.name ?? 'Unnamed Task',
            style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
            ),
            child: const Icon(Icons.task, color: Colors.white),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${task.referredSavingVO?.savingName ?? 'N/A'} (${task.moneyStorage?.shortName ?? 'N/A'})',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14.0),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'RM ${(task.amount ?? .0).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showConfirmDialog(
                        context: context,
                        message: "Task completed?",
                        onConfirm: () async {
                          BlocProvider.of<CommitmentTaskBloc>(
                            context,
                          ).add(UpdateStatusCommitmentTaskEvent(true, task));
                        },
                      ),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Complete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => showConfirmDialog(
                        context: context,
                        message: "Remove task?",
                        onConfirm: () async {
                          BlocProvider.of<CommitmentTaskBloc>(
                            context,
                          ).add(UpdateStatusCommitmentTaskEvent(false, task));
                        },
                      ),
                      icon: const Icon(Icons.cancel, size: 18),
                      label: const Text('Remove'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
