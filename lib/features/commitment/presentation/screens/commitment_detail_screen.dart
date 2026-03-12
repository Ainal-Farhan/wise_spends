import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_detail_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_bloc.dart';
import 'package:wise_spends/features/commitment/presentation/widgets/forms/commitment_detail_form.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/components/components.dart';

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
      create: (_) => CommitmentBloc()..add(LoadDetailScreenEvent(commitmentId)),
      child: _CommitmentDetailScreenContent(
        commitmentId: commitmentId,
        commitmentName: commitmentName,
      ),
    );
  }
}

class _CommitmentDetailScreenContent extends StatelessWidget {
  final String commitmentId;
  final String commitmentName;

  const _CommitmentDetailScreenContent({
    required this.commitmentId,
    required this.commitmentName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(commitmentName),
        actions: [
          BlocBuilder<CommitmentBloc, CommitmentState>(
            builder: (context, state) {
              if (state is CommitmentStateDetailScreenReady) {
                return IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add detail',
                  onPressed: () =>
                      _showDetailForm(context, state, CommitmentDetailVO()),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: (context, state) {
          if (state is CommitmentStateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );
            context.read<CommitmentBloc>().add(state.nextEvent);
          } else if (state is CommitmentStateError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommitmentStateError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () => context.read<CommitmentBloc>().add(
                LoadDetailScreenEvent(commitmentId),
              ),
            );
          }

          if (state is CommitmentStateDetailScreenReady) {
            final details = state.commitmentDetails;

            if (details.isEmpty) {
              return _buildEmptyState(context, state);
            }

            return RefreshIndicator(
              onRefresh: () async => context.read<CommitmentBloc>().add(
                LoadDetailScreenEvent(commitmentId),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: details.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) =>
                    _buildDetailCard(context, state, details[index]),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    CommitmentStateDetailScreenReady state,
    CommitmentDetailVO detail,
  ) {
    final typeColor = _colorForType(detail.taskType);
    final typeIcon = _iconForType(detail.taskType);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(typeIcon, color: typeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.description ?? 'Unnamed Detail',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _typeLabel(detail.taskType),
                      style: TextStyle(
                        fontSize: 12,
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  NumberFormat.currency(
                    symbol: 'RM ',
                    decimalDigits: 2,
                  ).format(detail.amount ?? 0.0),
                  style: AppTextStyles.amountSmall.copyWith(
                    color: AppColors.tertiary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: Colors.grey.shade200),
          const SizedBox(height: 10),
          _buildRouteRow(detail),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _showDetailForm(context, state, detail),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: Text('general.edit'.tr),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
              TextButton.icon(
                onPressed: () async {
                  final confirmed = await showDeleteDialog(
                    context: context,
                    title: 'Delete Detail',
                    message:
                        'Are you sure you want to delete this commitment detail?',
                    deleteText: 'Delete',
                    autoDisplayMessage: true,
                  );
                  if (confirmed == true) {
                    context.read<CommitmentBloc>().add(
                      DeleteCommitmentDetailEvent(
                        detail.commitmentDetailId!,
                        commitmentId: commitmentId,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text('general.delete'.tr),
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(CommitmentDetailVO detail) {
    switch (detail.taskType) {
      case CommitmentTaskType.internalTransfer:
        return _RouteRow(
          from: detail.sourceSavingName,
          to: detail.targetSavingName,
          icon: Icons.swap_horiz_rounded,
          color: Colors.blue,
        );
      case CommitmentTaskType.thirdPartyPayment:
        return _RouteRow(
          from: detail.sourceSavingName,
          to: detail.payeeName,
          icon: Icons.send_rounded,
          color: Colors.orange,
          toIsPayee: true,
        );
      case CommitmentTaskType.cash:
        return Row(
          children: [
            Icon(Icons.payments_outlined, size: 16, color: Colors.green[600]),
            const SizedBox(width: 6),
            Text(
              'Cash — no account affected',
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        );
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    CommitmentStateDetailScreenReady state,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.playlist_add_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text('commitments.no_details'.tr, style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add details to define how this commitment will be paid out on distribute.',
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
                onPressed: () =>
                    _showDetailForm(context, state, CommitmentDetailVO()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailForm(
    BuildContext context,
    CommitmentStateDetailScreenReady state,
    CommitmentDetailVO detail,
  ) {
    final bloc = context.read<CommitmentBloc>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: DraggableScrollableSheet(
          initialChildSize: 0.88,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, scrollController) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  CommitmentDetailForm(
                    commitmentDetailVO: detail,
                    savingVOList: state.savingVOList,
                    payeeVOList: state.payeeVOList,
                    commitmentId: commitmentId,
                    commitmentVO: state.commitmentVO, // ← passes parent VO
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForType(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return Colors.blue;
      case CommitmentTaskType.thirdPartyPayment:
        return Colors.orange;
      case CommitmentTaskType.cash:
        return Colors.green;
    }
  }

  IconData _iconForType(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return Icons.swap_horiz_rounded;
      case CommitmentTaskType.thirdPartyPayment:
        return Icons.send_rounded;
      case CommitmentTaskType.cash:
        return Icons.payments_outlined;
    }
  }

  String _typeLabel(CommitmentTaskType t) {
    switch (t) {
      case CommitmentTaskType.internalTransfer:
        return 'Internal Transfer';
      case CommitmentTaskType.thirdPartyPayment:
        return 'Third-Party Payment';
      case CommitmentTaskType.cash:
        return 'Cash';
    }
  }
}

class _RouteRow extends StatelessWidget {
  final String from;
  final String to;
  final IconData icon;
  final Color color;
  final bool toIsPayee;

  const _RouteRow({
    required this.from,
    required this.to,
    required this.icon,
    required this.color,
    this.toIsPayee = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.account_balance_wallet_outlined,
          size: 14,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            from,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Icon(icon, size: 16, color: color),
        ),
        if (toIsPayee) ...[
          Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
          const SizedBox(width: 4),
        ],
        Flexible(
          child: Text(
            to,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
