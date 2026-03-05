import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import '../commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';

/// Commitment Detail Screen - Manage commitment details and tasks
class CommitmentDetailScreen extends StatelessWidget {
  final String commitmentId;
  final String commitmentName;

  const CommitmentDetailScreen({
    super.key,
    required this.commitmentId,
    required this.commitmentName,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CommitmentBloc()..add(LoadCommitmentDetailEvent(commitmentId)),
      child: _CommitmentDetailScreenContent(
        commitmentId: commitmentId,
        commitmentName: commitmentName,
      ),
    );
  }
}

class _CommitmentDetailScreenContent extends StatefulWidget {
  final String commitmentId;
  final String commitmentName;

  const _CommitmentDetailScreenContent({
    required this.commitmentId,
    required this.commitmentName,
  });

  @override
  State<_CommitmentDetailScreenContent> createState() =>
      _CommitmentDetailScreenContentState();
}

class _CommitmentDetailScreenContentState
    extends State<_CommitmentDetailScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.commitmentName),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDetailDialog(context),
            tooltip: 'Add Task',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // Edit commitment
              } else if (value == 'distribute') {
                _confirmDistributeCommitment(context);
              } else if (value == 'delete') {
                _confirmDeleteCommitment(context);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'distribute',
                child: Row(
                  children: [
                    Icon(Icons.pie_chart, size: 18),
                    SizedBox(width: 8),
                    Text('Distribute'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: (context, state) {
          if (state is CommitmentStateSuccess) {
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

            context.read<CommitmentBloc>().add(state.nextEvent);
          } else if (state is CommitmentStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommitmentStateCommitmentDetailLoaded) {
            final details = state.commitmentDetails;

            if (details.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommitmentBloc>().add(
                  LoadCommitmentDetailEvent(widget.commitmentId),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: details.length,
                itemBuilder: (context, index) {
                  final detail = details[index];
                  return _buildDetailCard(context, detail);
                },
              ),
            );
          } else if (state is CommitmentStateError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () {
                context.read<CommitmentBloc>().add(
                  LoadCommitmentDetailEvent(widget.commitmentId),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_outlined, size: 80, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text('No tasks yet', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add tasks to track payments for this commitment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Add Task',
                icon: Icons.add,
                onPressed: () => _showAddDetailDialog(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, CommitmentDetailVO detail) {
    final amount = detail.amount ?? 0.0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        // Navigate to CommitmentTaskScreen to manage actual tasks
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommitmentTaskScreen(
              bloc: CommitmentTaskBloc(CommitmentTaskRepository()),
            ),
          ),
        );
      },
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.payment,
              color: AppColors.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  detail.description ?? 'Task',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'RM ${amount.toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: AppColors.tertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _showEditDetailDialog(context, detail);
              } else if (value == 'delete') {
                _confirmDeleteDetail(context, detail);
              } else if (value == 'mark_paid') {
                _confirmMarkAsPaid(context, detail);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'mark_paid',
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 18,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 8),
                    Text('Mark as Paid'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: AppColors.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
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

  void _showAddDetailDialog(BuildContext context) {
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String frequency = 'monthly';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Amount (RM)',
                controller: amountController,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.decimal,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description (Optional)',
                controller: descriptionController,
                hint: 'e.g., January payment',
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                    value: 'quarterly',
                    child: Text('Quarterly'),
                  ),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    frequency = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;
              if (amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid amount'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              final detailVO = CommitmentDetailVO();
              detailVO.amount = amount;
              detailVO.description = descriptionController.text.isEmpty
                  ? null
                  : descriptionController.text;

              context.read<CommitmentBloc>().add(
                SaveCommitmentDetailEvent(
                  commitmentId: widget.commitmentId,
                  commitmentDetailVO: detailVO,
                ),
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDetailDialog(BuildContext context, CommitmentDetailVO detail) {
    final amountController = TextEditingController(
      text: (detail.amount ?? 0.0).toStringAsFixed(2),
    );
    final descriptionController = TextEditingController(
      text: detail.description ?? '',
    );
    String frequency = 'monthly';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Amount (RM)',
                controller: amountController,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.decimal,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'Description',
                controller: descriptionController,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: frequency,
                decoration: const InputDecoration(labelText: 'Frequency'),
                items: const [
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                    value: 'quarterly',
                    child: Text('Quarterly'),
                  ),
                  DropdownMenuItem(value: 'yearly', child: Text('Yearly')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    frequency = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0.0;

              detail.amount = amount;
              detail.description = descriptionController.text.isEmpty
                  ? null
                  : descriptionController.text;

              context.read<CommitmentBloc>().add(
                SaveCommitmentDetailEvent(
                  commitmentId: widget.commitmentId,
                  commitmentDetailVO: detail,
                ),
              );

              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmMarkAsPaid(BuildContext context, CommitmentDetailVO detail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid?'),
        content: const Text(
          'Mark this task as paid? This will record the payment.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDetail(BuildContext context, CommitmentDetailVO detail) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task?'),
        content: const Text(
          'Are you sure you want to delete this task? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommitmentBloc>().add(
                DeleteCommitmentDetailEvent(
                  detail.commitmentDetailId!,
                  commitmentId: widget.commitmentId,
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _confirmDistributeCommitment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Distribute Commitment?'),
        content: const Text(
          'This will distribute the commitment across months based on the frequency. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Trigger distribution
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Distribute'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteCommitment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Commitment?'),
        content: const Text(
          'Are you sure you want to delete this commitment? All tasks will be deleted. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<CommitmentBloc>().add(
                DeleteCommitmentEvent(widget.commitmentId),
              );
              Navigator.pop(context);
              // Navigate back to list
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
