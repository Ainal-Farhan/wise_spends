import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/features/commitment/presentation/bloc/commitment_bloc.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import '../widgets/commitment/commitment_card.dart';
import '../widgets/shared/commitment_snack_bar.dart';
import 'commitment_detail_screen.dart';
import 'add_commitment_screen.dart';
import 'edit_commitment_screen.dart';

class CommitmentScreen extends StatelessWidget {
  const CommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CommitmentBloc()..add(const LoadCommitmentsEvent()),
      child: const _CommitmentScreenContent(),
    );
  }
}

class _CommitmentScreenContent extends StatelessWidget {
  const _CommitmentScreenContent();

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _goToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddCommitmentScreen()),
    ).then(
      (_) => context.read<CommitmentBloc>().add(const LoadCommitmentsEvent()),
    );
  }

  void _goToEdit(BuildContext context, CommitmentVO commitment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditCommitmentScreen(commitment: commitment),
      ),
    ).then(
      (_) => context.read<CommitmentBloc>().add(const LoadCommitmentsEvent()),
    );
  }

  void _goToDetails(BuildContext context, CommitmentVO commitment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommitmentDetailScreen(
          commitmentId: commitment.commitmentId!,
          commitmentName: commitment.name ?? 'commitments.unnamed'.tr,
        ),
      ),
    ).then(
      (_) => context.read<CommitmentBloc>().add(const LoadCommitmentsEvent()),
    );
  }

  // ---------------------------------------------------------------------------
  // Dialogs
  // ---------------------------------------------------------------------------

  void _confirmDistribute(BuildContext context, CommitmentVO commitment) {
    final detailCount = commitment.commitmentDetailVOList.length;
    final totalAmount = commitment.totalAmount ?? 0.0;
    final name = commitment.name ?? 'commitments.this_commitment'.tr;

    showConfirmDialog(
      context: context,
      title: 'commitments.distribute_commitment'.tr,
      message: 'commitments.distribute_msg'.trWith({
        'count': '$detailCount',
        'plural': detailCount == 1 ? '' : 's',
        'name': name,
      }),
      confirmText: 'commitments.distribute'.tr,
      cancelText: 'general.cancel'.tr,
      icon: Icons.send_and_archive_rounded,
      iconColor: Colors.green,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                Text(
                  'commitments.total_to_distribute'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  NumberFormat.currency(
                    symbol: '${'general.currency'.tr} ',
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
          Text(
            'commitments.distribute_task_msg'.tr,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      onConfirm: () => context.read<CommitmentBloc>().add(
        StartDistributeCommitmentEvent(commitment),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CommitmentVO commitment) {
    showDeleteDialog(
      context: context,
      title: 'commitments.delete'.tr,
      message: 'commitments.delete_msg'.tr,
      deleteText: 'general.delete'.tr,
      cancelText: 'general.cancel'.tr,
      onDelete: () => context.read<CommitmentBloc>().add(
        DeleteCommitmentEvent(commitment.commitmentId!),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BLoC listener
  // ---------------------------------------------------------------------------

  void _handleState(BuildContext context, CommitmentState state) {
    if (state is CommitmentStateSuccess) {
      showCommitmentSnackBar(
        context,
        message: state.message,
        icon: Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
      );
      context.read<CommitmentBloc>().add(state.nextEvent);
    } else if (state is CommitmentStateDistributionSuccess) {
      showCommitmentSnackBar(
        context,
        message: state.message,
        icon: Icons.send_and_archive_rounded,
        color: Colors.green,
        duration: const Duration(seconds: 4),
      );
      context.read<CommitmentBloc>().add(const LoadCommitmentsEvent());
    } else if (state is CommitmentStateError) {
      showCommitmentSnackBar(
        context,
        message: state.message,
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('commitments.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _goToAdd(context),
            tooltip: 'commitments.add'.tr,
          ),
        ],
      ),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: _handleState,
        builder: (context, state) {
          if (state is CommitmentStateLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CommitmentStateCommitmentsLoaded) {
            final commitments = state.commitments;
            return RefreshIndicator(
              onRefresh: () async => context.read<CommitmentBloc>().add(
                const LoadCommitmentsEvent(),
              ),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: commitments.isEmpty ? 2 : commitments.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return _buildHeaderCard();
                  if (commitments.isEmpty) return _buildEmptyState(context);
                  final commitment = commitments[index - 1];
                  return CommitmentCard(
                    commitment: commitment,
                    onDetails: () => _goToDetails(context, commitment),
                    onDistribute: () => _confirmDistribute(context, commitment),
                    onEdit: () => _goToEdit(context, commitment),
                    onDelete: () => _confirmDelete(context, commitment),
                  );
                },
              ),
            );
          }

          if (state is CommitmentStateError) {
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

  Widget _buildHeaderCard() {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF42A5F5), Color(0xFF42A5F5)],
      ),
      icon: Icons.calendar_month,
      label: 'general.commitment_overview'.tr,
      title: 'general.manage_recurring'.tr,
      subtitle: 'commitments.subtitle'.tr,
      learnMoreLabel: 'general.learn_more'.tr,
      learnLessLabel: 'general.less'.tr,
      collapsibleBody: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'commitments.what_are'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'commitments.what_are_desc'.tr,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 10),
          SectionHeaderBullet('commitments.example_rent'.tr),
          SectionHeaderBullet('commitments.example_insurance'.tr),
          SectionHeaderBullet('commitments.example_streaming'.tr),
          SectionHeaderBullet('commitments.example_utilities'.tr),
          SectionHeaderBullet('commitments.example_loan'.tr),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text('commitments.no_commitments'.tr, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'general.tap_button_below'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: AppButton.primary(
              label: 'commitments.add'.tr,
              icon: Icons.add,
              onPressed: () => _goToAdd(context),
            ),
          ),
        ],
      ),
    );
  }
}
