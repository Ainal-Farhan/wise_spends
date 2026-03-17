import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/commitment/domain/entities/commitment_vo.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Card widget representing a single [CommitmentVO] in the commitment list.
///
/// All interactions are surfaced as callbacks so the parent screen owns
/// navigation and BLoC dispatching.
///
/// Example:
/// ```dart
/// CommitmentCard(
///   commitment: commitment,
///   onDetails: () => Navigator.push(...),
///   onDistribute: () => _confirmDistribute(commitment),
///   onEdit: () => _navigateToEdit(commitment),
///   onDelete: () => _confirmDelete(commitment),
/// )
/// ```
class CommitmentCard extends StatelessWidget {
  final CommitmentVO commitment;
  final VoidCallback onDetails;
  final VoidCallback? onDistribute; // null when there are no details yet
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CommitmentCard({
    super.key,
    required this.commitment,
    required this.onDetails,
    this.onDistribute,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = commitment.totalAmount ?? 0.0;
    final detailCount = commitment.commitmentDetailVOList.length;
    final hasDetails = detailCount > 0;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.tertiary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Color(0xFF42A5F5),
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
                    if (commitment.description?.isNotEmpty == true) ...[
                      const SizedBox(height: 2),
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
              _OverflowMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
          const SizedBox(height: 16),

          // ── Amount + detail count ─────────────────────────────────────────
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
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$detailCount ${'general.details'.tr}',
                    style: AppTextStyles.caption,
                  ),
                  if (hasDetails)
                    Text(
                      'general.tap_to_manage'.tr,
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Action buttons ────────────────────────────────────────────────
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDetails,
                  icon: const Icon(Icons.list_alt_rounded, size: 16),
                  label: Text('commitments.details'.tr),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.5),
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
                  onPressed: hasDetails ? onDistribute : null,
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
}

// ---------------------------------------------------------------------------
// Private overflow menu
// ---------------------------------------------------------------------------

class _OverflowMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _OverflowMenu({required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_CommitmentAction>(
      icon: Icon(
        Icons.more_vert,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      onSelected: (action) {
        switch (action) {
          case _CommitmentAction.edit:
            onEdit();
          case _CommitmentAction.delete:
            onDelete();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _CommitmentAction.edit,
          child: Row(
            children: [
              Icon(
                Icons.edit,
                size: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              const SizedBox(width: 8),
              Text('commitments.edit'.tr),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CommitmentAction.delete,
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 8),
              Text(
                'general.delete'.tr,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _CommitmentAction { edit, delete }
