import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';
import 'package:wise_spends/presentation/screens/commitment_task/commitment_task_screen.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/components/forms/commitment_form.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_detail_vo.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
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
            tooltip: 'Add Detail',
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
          // Distribution succeeded — navigate to task screen
          if (state is CommitmentStateDistributionSuccess) {
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
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => CommitmentTaskScreen(
                  bloc: CommitmentTaskBloc(CommitmentTaskRepository()),
                ),
              ),
              (route) => route.isFirst,
            );
            return;
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

  /// Returns the full CommitmentVO from state (including referredSavingVO).
  /// Falls back to a minimal VO built from widget params if state is not ready.
  CommitmentVO _getCommitmentVOFromState() {
    final state = context.read<CommitmentBloc>().state;
    if (state is CommitmentStateDetailScreenReady &&
        state.commitmentVO != null) {
      // Ensure details are up to date from state
      return state.commitmentVO!
        ..commitmentDetailVOList = state.commitmentDetails;
    }
    if (state is CommitmentStateCommitmentFormLoaded) {
      return state.commitmentVO;
    }
    return CommitmentVO()
      ..commitmentId = widget.commitmentId
      ..name = widget.commitmentName;
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
            Text('No details yet', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add details to define the recurring payments for this commitment',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Add Detail',
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForDetailType(detail.type),
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
                  detail.description ?? 'Detail',
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (detail.referredSavingVO?.savingName != null)
                      Expanded(
                        child: Text(
                          detail.referredSavingVO!.savingName!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    if (detail.type != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tertiary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _labelForDetailType(detail.type),
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
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

  IconData _iconForDetailType(CommitmentDetailType? type) {
    switch (type) {
      case CommitmentDetailType.monthly:
        return Icons.calendar_month;
      case CommitmentDetailType.weekly:
        return Icons.calendar_view_week;
      case CommitmentDetailType.quarterly:
        return Icons.date_range;
      case CommitmentDetailType.yearly:
        return Icons.event_repeat;
      case CommitmentDetailType.oneOff:
        return Icons.looks_one_outlined;
      case null:
        return Icons.payment;
    }
  }

  String _labelForDetailType(CommitmentDetailType? type) {
    switch (type) {
      case CommitmentDetailType.monthly:
        return 'Monthly';
      case CommitmentDetailType.weekly:
        return 'Weekly';
      case CommitmentDetailType.quarterly:
        return 'Quarterly';
      case CommitmentDetailType.yearly:
        return 'Yearly';
      case CommitmentDetailType.oneOff:
        return 'One-off';
      case null:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  void _openEditCommitmentScreen() {
    final bloc = context.read<CommitmentBloc>();
    bloc.add(EditCommitmentEvent(_getCommitmentVOFromState()));

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
      title: 'Add Detail',
      confirmLabel: 'Add',
      savings: _getSavingsFromState(),
      onConfirm:
          ({
            required double amount,
            required String? description,
            required String savingId,
            required CommitmentDetailType type,
          }) {
            context.read<CommitmentBloc>().add(
              SaveCommitmentDetailEvent(
                commitmentId: widget.commitmentId,
                commitmentDetailVO: CommitmentDetailVO()
                  ..amount = amount
                  ..description = description
                  ..savingId = savingId
                  ..type = type,
              ),
            );
          },
    );
  }

  void _openEditDetailDialog(CommitmentDetailVO detail) {
    _showDetailDialog(
      title: 'Edit Detail',
      confirmLabel: 'Update',
      savings: _getSavingsFromState(),
      initialAmount: detail.amount,
      initialDescription: detail.description,
      initialSavingId: detail.savingId ?? detail.referredSavingVO?.savingId,
      initialType: detail.type,
      onConfirm:
          ({
            required double amount,
            required String? description,
            required String savingId,
            required CommitmentDetailType type,
          }) {
            context.read<CommitmentBloc>().add(
              SaveCommitmentDetailEvent(
                commitmentId: widget.commitmentId,
                commitmentDetailVO: detail
                  ..amount = amount
                  ..description = description
                  ..savingId = savingId
                  ..type = type,
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
    CommitmentDetailType? initialType,
    required void Function({
      required double amount,
      required String? description,
      required String savingId,
      required CommitmentDetailType type,
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
    CommitmentDetailType selectedType =
        initialType ?? CommitmentDetailType.monthly;

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
                  hint: 'e.g., Monthly rent',
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                // Recurrence type — drives how many tasks get generated on distribute
                DropdownButtonFormField<CommitmentDetailType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Recurrence',
                    prefixIcon: Icon(Icons.repeat),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                  ),
                  items: CommitmentDetailType.values
                      .map(
                        (t) => DropdownMenuItem(
                          value: t,
                          child: Text(_labelForDetailType(t)),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => selectedType = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: selectedSavingId,
                  decoration: const InputDecoration(
                    labelText: 'Target Savings Account',
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
                  description: descriptionController.text.trim().isEmpty
                      ? null
                      : descriptionController.text.trim(),
                  savingId: selectedSavingId!,
                  type: selectedType,
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
          'Delete Detail?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: const Text(
          'Are you sure? Any tasks generated from this detail will also be deleted.',
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

  /// Distribute uses the commitmentVO already in state — no extra load needed.
  /// The manager reads detail.savingId as targetSavingId for each task and
  /// commitment.referredSavingId as the sourceSavingId.
  void _confirmDistributeCommitment() {
    final commitmentVO = _getCommitmentVOFromState();

    if (commitmentVO.commitmentDetailVOList.isEmpty) {
      _showInlineError('Add at least one detail before distributing.');
      return;
    }

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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This will generate tasks for each detail based on their recurrence. Continue?',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            // Preview the details that will be distributed
            ...commitmentVO.commitmentDetailVOList.map(
              (d) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.arrow_right,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${d.description ?? 'Detail'} — RM ${(d.amount ?? 0).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
              // commitmentVO already has referredSavingVO from _onLoadDetailScreen
              // No extra load required — dispatch directly.
              context.read<CommitmentBloc>().add(
                StartDistributeCommitmentEvent(commitmentVO),
              );
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
          'Are you sure? All details and generated tasks will be deleted. This cannot be undone.',
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
