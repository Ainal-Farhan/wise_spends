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

/// Combined Commitment Screen - Header + list in a single layer
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

class _CommitmentScreenContent extends StatefulWidget {
  const _CommitmentScreenContent();

  @override
  State<_CommitmentScreenContent> createState() =>
      _CommitmentScreenContentState();
}

class _CommitmentScreenContentState extends State<_CommitmentScreenContent>
    with SingleTickerProviderStateMixin {
  bool _isIntroExpanded = false;
  late final AnimationController _animController;
  late final Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleIntro() {
    setState(() => _isIntroExpanded = !_isIntroExpanded);
    if (_isIntroExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('commitments.title'.tr),
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

            return RefreshIndicator(
              onRefresh: () async {
                context.read<CommitmentBloc>().add(
                  const LoadCommitmentsEvent(),
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                // +1 for the header card, +1 if empty state
                itemCount: commitments.isEmpty ? 2 : commitments.length + 1,
                itemBuilder: (context, index) {
                  // First item is always the header card
                  if (index == 0) {
                    return _buildHeaderCard();
                  }

                  if (commitments.isEmpty) {
                    return _buildEmptyState(context);
                  }

                  return _buildCommitmentCard(context, commitments[index - 1]);
                },
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
  // Header card with collapsible intro
  // ---------------------------------------------------------------------------

  Widget _buildHeaderCard() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: AppCard.gradient(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.tertiary, AppColors.tertiaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Always-visible header row ──────────────────────────────────
            Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  color: Colors.white70,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Commitment Overview',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // "Learn more" toggle button
                GestureDetector(
                  onTap: _toggleIntro,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isIntroExpanded ? 'Less' : 'Learn more',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _isIntroExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 280),
                          child: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Always-visible title + subtitle ───────────────────────────
            const Text(
              'Manage Recurring Expenses',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track bills, subscriptions, and regular payments',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),

            // ── Collapsible intro section ──────────────────────────────────
            SizeTransition(
              sizeFactor: _expandAnimation,
              axisAlignment: -1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'What are commitments?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Commitments are recurring expenses you pay regularly, such as:',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  ...[
                    'Rent or mortgage payments',
                    'Car insurance',
                    'Streaming subscriptions (Netflix, Spotify)',
                    'Utility bills',
                    'Loan payments',
                  ].map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '• ',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
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
                        const Text(
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
                  Text(
                    'commitments.total_amount'.tr,
                    style: AppTextStyles.caption,
                  ),
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
  // Distribute confirmation
  // ---------------------------------------------------------------------------

  void _confirmDistribute(BuildContext context, CommitmentVO commitment) {
    final detailCount = commitment.commitmentDetailVOList.length;
    final totalAmount = commitment.totalAmount ?? 0.0;

    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Distribute Commitment?',
          message:
              'This will create $detailCount task${detailCount == 1 ? '' : 's'} '
              'from "${commitment.name ?? 'this commitment'}".',
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
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Distribute',
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
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete Commitment?',
          message:
              'Are you sure you want to delete this commitment? '
              'All associated tasks will be deleted. This cannot be undone.',
          icon: Icons.delete_outline,
          iconColor: AppColors.secondary,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Delete',
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
}
