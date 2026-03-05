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

/// Commitment List Screen - Main screen to view and manage all commitments
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

            // Reload commitments after success
            context.read<CommitmentBloc>().add(state.nextEvent);
          } else if (state is CommitmentStateError) {
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
                itemBuilder: (context, index) {
                  final commitment = commitments[index];
                  return _buildCommitmentCard(context, commitment);
                },
              ),
            );
          } else if (state is CommitmentStateError) {
            return ErrorStateWidget(
              message: state.message,
              onAction: () {
                context.read<CommitmentBloc>().add(
                  const LoadCommitmentsEvent(),
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

  Widget _buildCommitmentCard(BuildContext context, CommitmentVO commitment) {
    final totalAmount = commitment.totalAmount ?? 0.0;
    final detailCount = commitment.commitmentDetailVOList.length;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommitmentDetailScreen(
              commitmentId: commitment.commitmentId!,
              commitmentName: commitment.name ?? 'Unnamed',
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
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(height: 16),
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
                    '$detailCount ${detailCount == 1 ? 'task' : 'tasks'}',
                    style: AppTextStyles.caption,
                  ),
                  if (detailCount > 0)
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
        ],
      ),
    );
  }

  void _navigateToAddCommitment(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddCommitmentScreen()),
    ).then((_) {
      // Reload commitments when returning
      context.read<CommitmentBloc>().add(const LoadCommitmentsEvent());
    });
  }
}
