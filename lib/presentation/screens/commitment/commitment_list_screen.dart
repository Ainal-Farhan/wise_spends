import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'commitment_detail_screen.dart';
import 'add_commitment_screen.dart';
import 'edit_commitment_screen.dart';

class CommitmentListScreen extends StatelessWidget {
  const CommitmentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommitmentBloc()..add(const LoadCommitmentsEvent()),
      child: const _CommitmentListScreenContent(),
    );
  }
}

class _CommitmentListScreenContent extends StatefulWidget {
  const _CommitmentListScreenContent();

  @override
  State<_CommitmentListScreenContent> createState() =>
      _CommitmentListScreenContentState();
}

class _CommitmentListScreenContentState
    extends State<_CommitmentListScreenContent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Commitments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCommitment(context),
            tooltip: 'Add Commitment',
          ),
        ],
      ),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: (context, state) {
          if (state is CommitmentStateSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
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
          } else if (state is CommitmentStateDistributionSuccess) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(
                        Icons.send_and_archive_rounded,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
                    ],
                  ),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            context.read<CommitmentBloc>().add(const LoadCommitmentsEvent());
          } else if (state is CommitmentStateError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Expanded(child: Text(state.message)),
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
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CommitmentStateCommitmentsLoaded) {
            final commitments = state.commitments;

            if (commitments.isEmpty) {
              return _buildEmptyState(context);
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommitmentBloc>().add(
                  const LoadCommitmentsEvent(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: commitments.length,
                itemBuilder: (context, index) =>
                    _buildCommitmentCard(context, commitments[index]),
              ),
            );
          } else if (state is CommitmentStateError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () => context.read<CommitmentBloc>().add(
                const LoadCommitmentsEvent(),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text('No commitments yet', style: AppTextStyles.h3),
            const SizedBox(height: 8),
            Text(
              'Add your first recurring expense to track bills and subscriptions',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: AppButton.primary(
                label: 'Add Commitment',
                icon: Icons.add,
                onPressed: () => _navigateToAddCommitment(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Commitment card
  // ---------------------------------------------------------------------------

  Widget _buildCommitmentCard(BuildContext context, CommitmentVO commitment) {
    final totalAmount = commitment.totalAmount ?? 0.0;
    final detailCount = commitment.commitmentDetailVOList.length;
    final hasDetails = detailCount > 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: icon + name + overflow menu ──────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
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
                      commitment.name ?? 'Unnamed Commitment',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (commitment.description != null &&
                        commitment.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        commitment.description!,
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    _navigateToEditCommitment(context, commitment);
                  } else if (value == 'delete') {
                    _confirmDeleteCommitment(context, commitment);
                  }
                },
                itemBuilder: (context) => [
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
                        Icon(
                          Icons.delete,
                          size: 18,
                          color: AppColors.secondary,
                        ),
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
          const SizedBox(height: 16),

          // ── Amount + detail count ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Amount', style: AppTextStyles.caption),
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 2,
                    ).format(totalAmount),
                    style: AppTextStyles.amountSmall.copyWith(
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$detailCount ${detailCount == 1 ? 'detail' : 'details'}',
                    style: AppTextStyles.caption,
                  ),
                  if (hasDetails)
                    Text(
                      'Tap to manage',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Action buttons ─────────────────────────────────────────────────
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              // Details button
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommitmentDetailScreen(
                            commitmentId: commitment.commitmentId!,
                            commitmentName: commitment.name ?? 'Unnamed',
                          ),
                        ),
                      ).then(
                        (_) => context.read<CommitmentBloc>().add(
                          const LoadCommitmentsEvent(),
                        ),
                      ),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: const Text('Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Distribute button — disabled when no details exist
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasDetails
                      ? () => _confirmDistribute(context, commitment)
                      : null,
                  icon: const Icon(Icons.send_and_archive_rounded, size: 16),
                  label: const Text('Distribute'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    textStyle: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Distribute confirmation
  // ---------------------------------------------------------------------------

  void _confirmDistribute(BuildContext context, CommitmentVO commitment) {
    final detailCount = commitment.commitmentDetailVOList.length;
    final totalAmount = commitment.totalAmount ?? 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.send_and_archive_rounded, color: Colors.green),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Distribute Commitment?',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will create $detailCount task${detailCount == 1 ? '' : 's'} '
              'from "${commitment.name ?? 'this commitment'}".',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total to distribute',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: 'RM ',
                      decimalDigits: 2,
                    ).format(totalAmount),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Each task will use the payment method configured in its detail.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CommitmentBloc>().add(
                StartDistributeCommitmentEvent(commitment),
              );
            },
            icon: const Icon(Icons.send_and_archive_rounded, size: 16),
            label: const Text('Distribute'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Navigation helpers
  // ---------------------------------------------------------------------------

  void _navigateToAddCommitment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCommitmentScreen()),
    ).then(
      (_) => context.read<CommitmentBloc>().add(const LoadCommitmentsEvent()),
    );
  }

  void _navigateToEditCommitment(
    BuildContext context,
    CommitmentVO commitment,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCommitmentScreen(commitment: commitment),
      ),
    ).then(
      (_) => context.read<CommitmentBloc>().add(const LoadCommitmentsEvent()),
    );
  }

  void _confirmDeleteCommitment(BuildContext context, CommitmentVO commitment) {
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
          'Are you sure you want to delete this commitment? '
          'All associated tasks will be deleted. This cannot be undone.',
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
                DeleteCommitmentEvent(commitment.commitmentId!),
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
}
