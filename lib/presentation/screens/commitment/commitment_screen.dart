import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_bloc.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_vo.dart';
import 'commitment_detail_screen.dart';
import 'add_commitment_screen.dart';
import 'edit_commitment_screen.dart';

/// Combined Commitment Screen — header + list in a single layer.
class CommitmentScreen extends StatelessWidget {
  const CommitmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CommitmentBloc()..add(const LoadCommitmentsEvent()),
      child: const _CommitmentScreenContent(),
    );
  }
}

// =============================================================================
// Content
// =============================================================================

class _CommitmentScreenContent extends StatelessWidget {
  const _CommitmentScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('commitments.title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddCommitment(context),
            tooltip: 'commitments.add'.tr,
          ),
        ],
      ),
      body: BlocConsumer<CommitmentBloc, CommitmentState>(
        listener: _handleStateListener,
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
                  return _buildCommitmentCard(context, commitments[index - 1]);
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

  // ---------------------------------------------------------------------------
  // BLoC listener
  // ---------------------------------------------------------------------------

  void _handleStateListener(BuildContext context, CommitmentState state) {
    if (state is CommitmentStateSuccess) {
      _showSnackBar(
        context,
        message: state.message,
        icon: Icons.check_circle,
        color: AppColors.success,
      );
      context.read<CommitmentBloc>().add(state.nextEvent);
    } else if (state is CommitmentStateDistributionSuccess) {
      _showSnackBar(
        context,
        message: state.message,
        icon: Icons.send_and_archive_rounded,
        color: Colors.green,
        duration: const Duration(seconds: 4),
      );
      context.read<CommitmentBloc>().add(const LoadCommitmentsEvent());
    } else if (state is CommitmentStateError) {
      _showSnackBar(
        context,
        message: state.message,
        icon: Icons.error_outline,
        color: AppColors.error,
      );
    }
  }

  void _showSnackBar(
    BuildContext context, {
    required String message,
    required IconData icon,
    required Color color,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          duration: duration,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------------------
  // Header card — uses reusable SectionHeader
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard() {
    return SectionHeader.card(
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.tertiary, AppColors.tertiaryDark],
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

  // ---------------------------------------------------------------------------
  // Empty state
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 80,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 16),
          Text('commitments.no_commitments'.tr, style: AppTextStyles.h3),
          const SizedBox(height: 8),
          Text(
            'general.tap_button_below'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: AppButton.primary(
              label: 'commitments.add'.tr,
              icon: Icons.add,
              onPressed: () => _navigateToAddCommitment(context),
            ),
          ),
        ],
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
    final detailLabel = '$detailCount ${'general.details'.tr}';

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
                      commitment.name ?? 'commitments.unnamed'.tr,
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
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 8),
                        Text('commitments.edit'.tr),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          size: 18,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'general.delete'.tr,
                          style: const TextStyle(color: AppColors.secondary),
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
                  Text(
                    'commitments.total_amount'.tr,
                    style: AppTextStyles.caption,
                  ),
                  Text(
                    NumberFormat.currency(
                      symbol: '${'general.currency'.tr} ',
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
                  Text(detailLabel, style: AppTextStyles.caption),
                  if (hasDetails)
                    Text(
                      'general.tap_to_manage'.tr,
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
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommitmentDetailScreen(
                            commitmentId: commitment.commitmentId!,
                            commitmentName:
                                commitment.name ?? 'commitments.unnamed'.tr,
                          ),
                        ),
                      ).then(
                        (_) => context.read<CommitmentBloc>().add(
                          const LoadCommitmentsEvent(),
                        ),
                      ),
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: Text('commitments.details'.tr),
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
              Expanded(
                child: FilledButton.icon(
                  onPressed: hasDetails
                      ? () => _confirmDistribute(context, commitment)
                      : null,
                  icon: const Icon(Icons.send_and_archive_rounded, size: 16),
                  label: Text('commitments.distribute'.tr),
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
  // Distribute confirmation dialog
  // ---------------------------------------------------------------------------

  void _confirmDistribute(BuildContext context, CommitmentVO commitment) {
    final detailCount = commitment.commitmentDetailVOList.length;
    final totalAmount = commitment.totalAmount ?? 0.0;
    final name = commitment.name ?? 'commitments.this_commitment'.tr;

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'commitments.distribute_commitment'.tr,
          message: 'commitments.distribute_msg'.trWith({
            'count': '$detailCount',
            'plural': detailCount == 1 ? '' : 's',
            'name': name,
          }),
          icon: Icons.send_and_archive_rounded,
          iconColor: AppColors.success,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'commitments.total_to_distribute'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
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
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'commitments.distribute'.tr,
              isDefault: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<CommitmentBloc>().add(
                  StartDistributeCommitmentEvent(commitment),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Delete confirmation dialog
  // ---------------------------------------------------------------------------

  void _confirmDeleteCommitment(BuildContext context, CommitmentVO commitment) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'commitments.delete'.tr,
          message: 'commitments.delete_msg'.tr,
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'general.delete'.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<CommitmentBloc>().add(
                  DeleteCommitmentEvent(commitment.commitmentId!),
                );
              },
            ),
          ],
        ),
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
}
