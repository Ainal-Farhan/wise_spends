import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_event.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_task_state.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_task_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';

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

class _CommitmentTaskScreenContent extends StatefulWidget {
  const _CommitmentTaskScreenContent();

  @override
  State<_CommitmentTaskScreenContent> createState() =>
      _CommitmentTaskScreenContentState();
}

class _CommitmentTaskScreenContentState
    extends State<_CommitmentTaskScreenContent> {
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
            onPressed: _showInfoDialog,
            tooltip: 'Info',
          ),
        ],
      ),
      body: BlocConsumer<CommitmentTaskBloc, CommitmentTaskState>(
        listener: (context, state) {
          if (state is CommitmentTaskUpdated) {
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          } else if (state is CommitmentTaskError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(state.message),
                    ],
                  ),
                  backgroundColor: Theme.of(context).colorScheme.error,
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
          }

          if (state is CommitmentTaskLoaded) {
            final filtered = _filterTasks(state.tasks, state.filterStatus);
            return RefreshIndicator(
              onRefresh: () async => context.read<CommitmentTaskBloc>().add(
                LoadCommitmentTasksEvent(),
              ),
              child: Column(
                children: [
                  _buildFilterChips(),
                  Expanded(
                    child: filtered.isEmpty
                        ? _buildEmptyState(context, state.filterStatus)
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: filtered.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _buildTaskCard(context, filtered[index]),
                          ),
                  ),
                ],
              ),
            );
          }

          if (state is CommitmentTaskError) {
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
                      state.message,
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers from state
  // ---------------------------------------------------------------------------

  List<ListSavingVO> _getSavingsFromState() {
    final state = context.read<CommitmentTaskBloc>().state;
    if (state is CommitmentTaskLoaded) return state.savingVOList;
    return [];
  }

  List<PayeeVO> _getPayeesFromState() {
    final state = context.read<CommitmentTaskBloc>().state;
    if (state is CommitmentTaskLoaded) return state.payeeVOList;
    return [];
  }

  // ---------------------------------------------------------------------------
  // Filter
  // ---------------------------------------------------------------------------

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
        final filterStatus = state is CommitmentTaskLoaded
            ? state.filterStatus
            : 'all';
        final isSelected = filterStatus == label.toLowerCase();

        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) => context.read<CommitmentTaskBloc>().add(
            FilterCommitmentTasksEvent(selected ? label.toLowerCase() : 'all'),
          ),
          selectedColor: Theme.of(context).colorScheme.tertiary,
          checkmarkColor: Colors.white,
          labelStyle: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
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
      default:
        return tasks;
    }
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context, String filterStatus) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 80, color: Theme.of(context).colorScheme.outline),
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

  // ---------------------------------------------------------------------------
  // Task card
  // ---------------------------------------------------------------------------

  Widget _buildTaskCard(BuildContext context, CommitmentTaskVO task) {
    final isDone = task.isDone == true;

    return AppCard(
      onTap: () => _showTaskDetailDialog(task),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 60,
            decoration: BoxDecoration(
              color: isDone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDone
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _iconForType(task.type),
              color: isDone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
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
                const SizedBox(height: 4),
                Text(
                  'RM ${(task.amount ?? 0.0).toStringAsFixed(2)}',
                  style: AppTextStyles.amountSmall.copyWith(
                    color: isDone ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.tertiary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _subtitleForTask(task),
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit') _showEditTaskDialog(task);
              if (value == 'delete') _confirmDeleteTask(task);
              if (value == 'complete') _confirmCompleteTask(task);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18),
                    SizedBox(width: 8),
                    Text('commitment_tasks.edit'.tr),
                  ],
                ),
              ),
              if (!isDone)
                PopupMenuItem(
                  value: 'complete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Text('commitment_tasks.mark_complete'.tr),
                    ],
                  ),
                ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18, color: Theme.of(context).colorScheme.secondary),
                    SizedBox(width: 8),
                    Text(
                      'Delete',
                      style: TextStyle(color: Theme.of(context).colorScheme.secondary),
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

  IconData _iconForType(CommitmentTaskType? type) {
    switch (type) {
      case CommitmentTaskType.internalTransfer:
        return Icons.swap_horiz;
      case CommitmentTaskType.thirdPartyPayment:
        return Icons.send;
      case CommitmentTaskType.cash:
        return Icons.payments_outlined;
      case null:
        return Icons.schedule;
    }
  }

  String _subtitleForTask(CommitmentTaskVO task) {
    switch (task.type) {
      case CommitmentTaskType.internalTransfer:
        return '${task.sourceSavingName} → ${task.targetSavingName}';
      case CommitmentTaskType.thirdPartyPayment:
        return '${task.sourceSavingName} → ${task.payeeName}';
      case CommitmentTaskType.cash:
        return 'Cash payment';
      case null:
        return '';
    }
  }

  String _labelForType(CommitmentTaskType? type) {
    switch (type) {
      case CommitmentTaskType.internalTransfer:
        return 'Internal Transfer';
      case CommitmentTaskType.thirdPartyPayment:
        return 'Third-Party Payment';
      case CommitmentTaskType.cash:
        return 'Cash';
      case null:
        return '—';
    }
  }

  // ---------------------------------------------------------------------------
  // Task detail dialog
  // ---------------------------------------------------------------------------

  void _showTaskDetailDialog(CommitmentTaskVO task) {
    final isDone = task.isDone == true;

    showCustomContentDialog(
      context: context,
      title: task.name ?? 'Unnamed Task',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow(
            'Amount',
            NumberFormat.currency(
              symbol: 'RM ',
              decimalDigits: 2,
            ).format(task.amount ?? 0.0),
          ),
          _buildDetailRow('Status', isDone ? 'Completed' : 'Pending'),
          _buildDetailRow('Type', _labelForType(task.type)),
          if (task.type == CommitmentTaskType.internalTransfer) ...[
            _buildDetailRow('From', task.sourceSavingName),
            _buildDetailRow('To', task.targetSavingName),
          ] else if (task.type == CommitmentTaskType.thirdPartyPayment) ...[
            _buildDetailRow('From', task.sourceSavingName),
            _buildDetailRow('Payee', task.payeeName),
            if (task.payeeVO?.bankName != null)
              _buildDetailRow('Bank', task.payeeVO!.bankName!),
            if (task.payeeVO?.accountNumber != null)
              _buildDetailRow('Account', task.payeeVO!.accountNumber!),
          ] else if (task.type == CommitmentTaskType.cash) ...[
            _buildDetailRow('Method', 'Cash'),
          ],
          if (task.note?.isNotEmpty == true)
            _buildDetailRow('Note', task.note!),
          if (task.paymentReference?.isNotEmpty == true)
            _buildDetailRow('Reference', task.paymentReference!),
        ],
      ),
      actions: [
        DialogAction(
          text: 'general.close'.tr,
          onPressed: () => Navigator.pop(context),
        ),
        if (!isDone)
          DialogAction(
            text: 'commitment_tasks.mark_complete'.tr,
            isPrimary: true,
            onPressed: () {
              Navigator.pop(context);
              _confirmCompleteTask(task);
            },
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Add / Edit task dialogs
  // ---------------------------------------------------------------------------

  void _showAddTaskDialog() {
    _showTaskDialog(
      title: 'Add Task',
      confirmLabel: 'Add',
      onConfirm: (task) =>
          context.read<CommitmentTaskBloc>().add(AddCommitmentTaskEvent(task)),
    );
  }

  void _showEditTaskDialog(CommitmentTaskVO task) {
    _showTaskDialog(
      title: 'Edit Task',
      confirmLabel: 'Update',
      initial: task,
      onConfirm: (updated) => context.read<CommitmentTaskBloc>().add(
        EditCommitmentTaskEvent(updated),
      ),
    );
  }

  /// Unified add/edit dialog with type-aware savings and payee pickers.
  /// Fields shown adapt to the selected [CommitmentTaskType]:
  ///   internalTransfer  → source saving + target saving
  ///   thirdPartyPayment → source saving + payee picker
  ///   cash              → no savings fields
  void _showTaskDialog({
    required String title,
    required String confirmLabel,
    CommitmentTaskVO? initial,
    required void Function(CommitmentTaskVO) onConfirm,
  }) {
    final savings = _getSavingsFromState();
    final payees = _getPayeesFromState();

    final nameController = TextEditingController(text: initial?.name ?? '');
    final amountController = TextEditingController(
      text: initial?.amount != null ? initial!.amount!.toStringAsFixed(2) : '',
    );
    final noteController = TextEditingController(text: initial?.note ?? '');
    final referenceController = TextEditingController(
      text: initial?.paymentReference ?? '',
    );

    CommitmentTaskType selectedType =
        initial?.type ?? CommitmentTaskType.internalTransfer;
    String? selectedSourceId = initial?.sourceSavingId;
    String? selectedTargetId = initial?.targetSavingId;
    String? selectedPayeeId = initial?.payeeId;

    showCustomContentDialog(
      context: context,
      title: title,
      isScrollable: true,
      content: StatefulBuilder(
        builder: (ctx, setDialogState) {
          // Rebuild type-specific fields on type change
          Widget typeSpecificFields() {
            switch (selectedType) {
              case CommitmentTaskType.internalTransfer:
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSourceId,
                      decoration: const InputDecoration(
                        labelText: 'Source Savings (From)',
                        prefixIcon: Icon(Icons.arrow_upward),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      hint: Text('commitment_tasks.select_source'.tr),
                      items: savings
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.saving.id,
                              child: Text(s.saving.name ?? 'Unnamed'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedSourceId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedTargetId,
                      decoration: const InputDecoration(
                        labelText: 'Target Savings (To)',
                        prefixIcon: Icon(Icons.arrow_downward),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      hint: Text('commitment_tasks.select_target'.tr),
                      items: savings
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.saving.id,
                              child: Text(s.saving.name ?? 'Unnamed'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedTargetId = v),
                    ),
                  ],
                );

              case CommitmentTaskType.thirdPartyPayment:
                return Column(
                  children: [
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSourceId,
                      decoration: const InputDecoration(
                        labelText: 'Source Savings (From)',
                        prefixIcon: Icon(Icons.arrow_upward),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      hint: Text('commitment_tasks.select_source'.tr),
                      items: savings
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.saving.id,
                              child: Text(s.saving.name ?? 'Unnamed'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) =>
                          setDialogState(() => selectedSourceId = v),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedPayeeId,
                      decoration: const InputDecoration(
                        labelText: 'Payee',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      hint: payees.isEmpty
                          ? Text('commitment_tasks.no_payees'.tr)
                          : Text('commitment_tasks.select_payee'.tr),
                      items: payees
                          .map(
                            (p) => DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name ?? 'Unnamed Payee'),
                            ),
                          )
                          .toList(),
                      onChanged: payees.isEmpty
                          ? null
                          : (v) => setDialogState(() => selectedPayeeId = v),
                    ),
                  ],
                );

              case CommitmentTaskType.cash:
                // No savings or payee needed
                return const SizedBox.shrink();
            }
          }

          return CustomDialog(
            config: CustomDialogConfig(
              title: title,
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppTextField(
                      label: 'Task Name',
                      controller: nameController,
                      hint: 'e.g., Monthly rent — March 2026',
                      prefixIcon: Icons.label_outline,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Amount (RM)',
                      controller: amountController,
                      prefixText: 'RM ',
                      keyboardType: AppTextFieldKeyboardType.decimal,
                      prefixIcon: Icons.attach_money,
                    ),
                    const SizedBox(height: 16),
                    // Payment type — drives which extra fields are shown
                    DropdownButtonFormField<CommitmentTaskType>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Payment Type',
                        prefixIcon: Icon(Icons.category_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                      ),
                      items: CommitmentTaskType.values
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(_labelForType(t)),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                            // Clear irrelevant fields when type changes
                            selectedSourceId = null;
                            selectedTargetId = null;
                            selectedPayeeId = null;
                          });
                        }
                      },
                    ),
                    // Type-specific pickers rendered inline
                    typeSpecificFields(),
                    const SizedBox(height: 16),
                    AppTextField(
                      label: 'Note (Optional)',
                      controller: noteController,
                      hint: 'Any additional info',
                      maxLines: 2,
                    ),
                    if (initial != null) ...[
                      const SizedBox(height: 16),
                      AppTextField(
                        label: 'Payment Reference (Optional)',
                        controller: referenceController,
                        hint: 'Receipt no., FPX ref., etc.',
                        prefixIcon: Icons.receipt_outlined,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        DialogAction(
          text: 'general.cancel'.tr,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          text: confirmLabel,
          isPrimary: true,
          onPressed: () {
            final name = nameController.text.trim();
            final amount = double.tryParse(amountController.text.trim());

            if (name.isEmpty) {
              _showInlineError('Please enter a task name');
              return;
            }
            if (amount == null || amount <= 0) {
              _showInlineError('Please enter a valid amount');
              return;
            }
            if (selectedType == CommitmentTaskType.internalTransfer) {
              if (selectedSourceId == null) {
                _showInlineError('Please select a source savings account');
                return;
              }
              if (selectedTargetId == null) {
                _showInlineError('Please select a target savings account');
                return;
              }
              if (selectedSourceId == selectedTargetId) {
                _showInlineError('Source and target savings must be different');
                return;
              }
            }
            if (selectedType == CommitmentTaskType.thirdPartyPayment) {
              if (selectedSourceId == null) {
                _showInlineError('Please select a source savings account');
                return;
              }
              if (selectedPayeeId == null) {
                _showInlineError('Please select a payee');
                return;
              }
            }

            Navigator.pop(context);

            final taskVO = (initial ?? CommitmentTaskVO())
              ..name = name
              ..amount = amount
              ..type = selectedType
              ..isDone = initial?.isDone ?? false
              ..sourceSavingId = selectedSourceId
              ..targetSavingId = selectedTargetId
              ..payeeId = selectedPayeeId
              ..note = noteController.text.trim().isEmpty
                  ? null
                  : noteController.text.trim()
              ..paymentReference = referenceController.text.trim().isEmpty
                  ? null
                  : referenceController.text.trim();

            // Attach VO objects so the card subtitle renders immediately
            // without waiting for a reload
            if (selectedSourceId != null) {
              taskVO.sourceSavingVO = savings
                  .where((s) => s.saving.id == selectedSourceId)
                  .map((s) => SavingVO.fromSvngSaving(s.saving))
                  .firstOrNull;
            }
            if (selectedTargetId != null) {
              taskVO.targetSavingVO = savings
                  .where((s) => s.saving.id == selectedTargetId)
                  .map((s) => SavingVO.fromSvngSaving(s.saving))
                  .firstOrNull;
            }
            if (selectedPayeeId != null) {
              taskVO.payeeVO = payees
                  .where((p) => p.id == selectedPayeeId)
                  .firstOrNull;
            }

            onConfirm(taskVO);
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Confirm dialogs
  // ---------------------------------------------------------------------------

  void _confirmCompleteTask(CommitmentTaskVO task) {
    showConfirmDialog(
      context: context,
      title: 'Complete Task?',
      message:
          'Mark this task as completed? This will update your savings balance.',
      confirmText: 'commitment_tasks.mark_complete'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.check_circle_outline,
      iconColor: Theme.of(context).colorScheme.primary,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          _buildDetailRow('Type', _labelForType(task.type)),
          if (task.type == CommitmentTaskType.internalTransfer) ...[
            _buildDetailRow('From', task.sourceSavingName),
            _buildDetailRow('To', task.targetSavingName),
          ] else if (task.type == CommitmentTaskType.thirdPartyPayment) ...[
            _buildDetailRow('From', task.sourceSavingName),
            _buildDetailRow('Payee', task.payeeName),
          ] else if (task.type == CommitmentTaskType.cash) ...[
            _buildDetailRow('Method', 'Cash — no account affected'),
          ],
        ],
      ),
      onConfirm: () {
        context.read<CommitmentTaskBloc>().add(
          UpdateStatusCommitmentTaskEvent(true, task),
        );
      },
    );
  }

  void _confirmDeleteTask(CommitmentTaskVO task) {
    showDeleteDialog(
      context: context,
      title: 'Delete Task?',
      message:
          'Are you sure you want to delete this task? This cannot be undone.',
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      onDelete: () {
        context.read<CommitmentTaskBloc>().add(DeleteCommitmentTaskEvent(task));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  void _showInlineError(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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

  void _showInfoDialog() {
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
}
