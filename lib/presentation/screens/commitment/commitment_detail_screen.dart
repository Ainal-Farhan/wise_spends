import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/forms/commitment_form.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import '../commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/presentation/blocs/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/data/repositories/expense/impl/commitment_task_repository.dart';

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
          CommitmentBloc()..add(LoadDetailScreenEvent(commitmentId)),
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
            onPressed: _openAddDetailDialog,
            tooltip: 'Add Task',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _openEditCommitmentScreen();
              } else if (value == 'distribute') {
                _confirmDistributeCommitment();
              } else if (value == 'delete') {
                _confirmDeleteCommitment();
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
          // Handle distribution success - navigate to Commitment Task screen
          if (state is CommitmentStateDistributionSuccess) {
            // Show success message
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
            // Navigate to Commitment Task screen, clearing the navigation stack
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => CommitmentTaskScreen(
                  bloc: CommitmentTaskBloc(CommitmentTaskRepository()),
                  commitmentId: state.commitmentId,
                ),
              ),
              (route) => route.isFirst, // Keep only the first route (home)
            );
          }

          if (state is CommitmentStateSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
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
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.message),
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
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommitmentStateDetailScreenReady) {
            final details = state.commitmentDetails;
            if (details.isEmpty) return _buildEmptyState(context);

            return RefreshIndicator(
              onRefresh: () async => context.read<CommitmentBloc>().add(
                LoadDetailScreenEvent(widget.commitmentId),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: details.length,
                itemBuilder: (context, index) =>
                    _buildDetailCard(context, details[index]),
              ),
            );
          }

          if (state is CommitmentStateError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () => context.read<CommitmentBloc>().add(
                LoadDetailScreenEvent(widget.commitmentId),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // State helpers
  // ---------------------------------------------------------------------------

  List<ListSavingVO> _getSavingsFromState() {
    final state = context.read<CommitmentBloc>().state;
    if (state is CommitmentStateDetailScreenReady) return state.savingVOList;
    return [];
  }

  CommitmentVO _buildCommitmentVO() {
    final state = context.read<CommitmentBloc>().state;

    // Try to get full commitment VO from state (includes referredSavingVO)
    if (state is CommitmentStateDetailScreenReady &&
        state.commitmentVO != null) {
      return state.commitmentVO!;
    }

    // Try form state
    if (state is CommitmentStateCommitmentFormLoaded) {
      return state.commitmentVO;
    }

    // Fallback: build from available data (won't have referredSavingVO)
    final vo = CommitmentVO()
      ..commitmentId = widget.commitmentId
      ..name = widget.commitmentName;
    if (state is CommitmentStateDetailScreenReady) {
      vo.commitmentDetailVOList = state.commitmentDetails;
    }
    return vo;
  }

  // ---------------------------------------------------------------------------
  // UI builders
  // ---------------------------------------------------------------------------

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
                onPressed: _openAddDetailDialog,
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
      onTap: null,
      child: Row(
        children: [
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
                if (detail.referredSavingVO?.savingName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail.referredSavingVO!.savingName!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') {
                _openEditDetailDialog(detail);
              } else if (value == 'delete') {
                _confirmDeleteDetail(detail);
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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Fires EditCommitmentEvent and listens for the form state, then pushes
  /// the edit screen. Subscription is cancelled after the first match.
  void _openEditCommitmentScreen() {
    final bloc = context.read<CommitmentBloc>();
    bloc.add(EditCommitmentEvent(_buildCommitmentVO()));

    late final StreamSubscription<CommitmentState> sub;
    sub = bloc.stream.listen((state) {
      if (state is CommitmentStateCommitmentFormLoaded) {
        sub.cancel();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: bloc,
              child: _CommitmentEditFormScreen(
                commitmentVO: state.commitmentVO,
                savingVOList: state.savingVOList,
              ),
            ),
          ),
        );
      }
    });
  }

  void _openAddDetailDialog() {
    _showDetailDialog(
      title: 'Add Task',
      confirmLabel: 'Add',
      savings: _getSavingsFromState(),
      onConfirm:
          ({
            required double amount,
            required String? description,
            required String savingId,
          }) {
            final detailVO = CommitmentDetailVO()
              ..amount = amount
              ..description = description
              ..savingId = savingId;
            context.read<CommitmentBloc>().add(
              SaveCommitmentDetailEvent(
                commitmentId: widget.commitmentId,
                commitmentDetailVO: detailVO,
              ),
            );
          },
    );
  }

  void _openEditDetailDialog(CommitmentDetailVO detail) {
    _showDetailDialog(
      title: 'Edit Task',
      confirmLabel: 'Update',
      savings: _getSavingsFromState(),
      initialAmount: detail.amount,
      initialDescription: detail.description,
      initialSavingId: detail.savingId ?? detail.referredSavingVO?.savingId,
      onConfirm:
          ({
            required double amount,
            required String? description,
            required String savingId,
          }) {
            detail
              ..amount = amount
              ..description = description
              ..savingId = savingId;
            context.read<CommitmentBloc>().add(
              SaveCommitmentDetailEvent(
                commitmentId: widget.commitmentId,
                commitmentDetailVO: detail,
              ),
            );
          },
    );
  }

  void _showDetailDialog({
    required String title,
    required String confirmLabel,
    required List<ListSavingVO> savings,
    double? initialAmount,
    String? initialDescription,
    String? initialSavingId,
    required void Function({
      required double amount,
      required String? description,
      required String savingId,
    })
    onConfirm,
  }) {
    final amountController = TextEditingController(
      text: initialAmount != null ? initialAmount.toStringAsFixed(2) : '',
    );
    final descriptionController = TextEditingController(
      text: initialDescription ?? '',
    );
    String? selectedSavingId = initialSavingId;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          title: Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
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
                  initialValue: selectedSavingId,
                  decoration: const InputDecoration(
                    labelText: 'Savings Account',
                    prefixIcon: Icon(Icons.savings),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  hint: savings.isEmpty
                      ? const Text('No savings accounts found')
                      : const Text('Select savings account'),
                  items: savings
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s.saving.id,
                          child: Text(s.saving.name ?? 'Unnamed'),
                        ),
                      )
                      .toList(),
                  onChanged: savings.isEmpty
                      ? null
                      : (value) =>
                            setDialogState(() => selectedSavingId = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (amount <= 0) {
                  _showInlineError('Please enter a valid amount');
                  return;
                }
                if (selectedSavingId == null) {
                  _showInlineError('Please select a savings account');
                  return;
                }
                Navigator.pop(dialogContext);
                onConfirm(
                  amount: amount,
                  description: descriptionController.text.isEmpty
                      ? null
                      : descriptionController.text,
                  savingId: selectedSavingId!,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  void _showInlineError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  void _confirmDeleteDetail(CommitmentDetailVO detail) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Task?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this task? This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommitmentBloc>().add(
                DeleteCommitmentDetailEvent(
                  detail.commitmentDetailId!,
                  commitmentId: widget.commitmentId,
                ),
              );
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

  void _confirmDistributeCommitment() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Distribute Commitment?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'This will distribute the commitment across months based on the frequency. Continue?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);

              // Get current state
              final state = context.read<CommitmentBloc>().state;

              // If we have DetailScreenReady state with commitmentVO, distribute immediately
              if (state is CommitmentStateDetailScreenReady &&
                  state.commitmentVO != null) {
                final commitmentVO = state.commitmentVO!;
                commitmentVO.commitmentId = widget.commitmentId;
                // Include current commitment details
                commitmentVO.commitmentDetailVOList = state.commitmentDetails;
                context.read<CommitmentBloc>().add(
                  StartDistributeCommitmentEvent(commitmentVO),
                );
              } else {
                // Need to load form first to get savings info
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Loading commitment details...'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                context.read<CommitmentBloc>().add(LoadCommitmentFormEvent());
                // Distribution will happen after form loads via BlocListener
              }
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

  void _confirmDeleteCommitment() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Delete Commitment?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure you want to delete this commitment? All tasks will be deleted. This cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommitmentBloc>().add(
                DeleteCommitmentEvent(widget.commitmentId),
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
}

class _CommitmentEditFormScreen extends StatelessWidget {
  final CommitmentVO commitmentVO;
  final List<ListSavingVO> savingVOList;

  const _CommitmentEditFormScreen({
    required this.commitmentVO,
    required this.savingVOList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Commitment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: CommitmentForm(
          commitmentVO: commitmentVO,
          savingVOList: savingVOList,
        ),
      ),
    );
  }
}
