import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/saving/domain/entities/reserve_vo.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Reusable reservation info icon widget
/// Displays an info icon that shows reservation details when tapped
class ReservationInfoIcon extends StatelessWidget {
  final SavingsReserveSummary reserveSummary;
  final double? iconSize;
  final Color? color;
  final IconData? iconData;
  final String? savingName;

  const ReservationInfoIcon({
    super.key,
    required this.reserveSummary,
    this.iconSize,
    this.color,
    this.iconData,
    this.savingName,
  });

  @override
  Widget build(BuildContext context) {
    if (!reserveSummary.hasReservations) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          showDragHandle: false,
          builder: (_) => ReservationDetailsSheet(
            reserveSummary: reserveSummary,
            savingName: savingName,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData ?? Icons.info_outline,
          size: iconSize ?? 16,
          color: color ?? Theme.of(context).colorScheme.tertiary,
        ),
      ),
    );
  }
}

/// Modal bottom sheet to show detailed reservation list
class ReservationDetailsSheet extends StatefulWidget {
  final SavingsReserveSummary reserveSummary;
  final String? savingName;

  const ReservationDetailsSheet({
    super.key,
    required this.reserveSummary,
    this.savingName,
  });

  @override
  State<ReservationDetailsSheet> createState() =>
      _ReservationDetailsSheetState();
}

class _ReservationDetailsSheetState extends State<ReservationDetailsSheet> {
  bool _showAllReservations = false;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      symbol: 'RM ',
      decimalDigits: 2,
    );

    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Header with optional saving name
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.savingName != null) ...[
                        Text(
                          widget.savingName!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        'savings.reservation_details'.tr,
                        style: AppTextStyles.h2,
                      ),
                      Text(
                        'savings.reservation_details_desc'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Current Amount Card - Full width row on top
            _buildCurrentAmountCard(
              context,
              amount: widget.reserveSummary.currentAmount,
              currencyFormat: currencyFormat,
            ),
            const SizedBox(height: AppSpacing.md),

            // Reserved and Transferable cards - Row below
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    label: 'savings.total_reserved'.tr,
                    amount: widget.reserveSummary.totalReserved,
                    color: Theme.of(context).colorScheme.error,
                    currencyFormat: currencyFormat,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildSummaryCard(
                    context,
                    label: 'savings.transferable_amount'.tr,
                    amount: widget.reserveSummary.transferableAmount,
                    color: Theme.of(context).colorScheme.primary,
                    currencyFormat: currencyFormat,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Reservation list header with count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'savings.reservations_breakdown'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${widget.reserveSummary.reservations.length} ${widget.reserveSummary.reservations.length == 1 ? 'item' : 'items'}',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: Theme.of(context).colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Scrollable reservation list with max height constraint
            _buildScrollableReservationList(
              context,
              widget.reserveSummary.reservations,
              currencyFormat,
            ),
            const SizedBox(height: AppSpacing.md),

            // Close button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'general.close'.tr,
                  style: AppTextStyles.labelLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentAmountCard(
    BuildContext context, {
    required double amount,
    required NumberFormat currencyFormat,
  }) {
    // Determine color and icon based on amount value
    final bool isNegative = amount < 0;
    final bool isZero = amount == 0;

    Color cardColor;
    Color textColor;
    IconData statusIcon;
    String statusLabel;

    if (isNegative) {
      // Negative - Error/Warning styling
      cardColor = Theme.of(context).colorScheme.errorContainer;
      textColor = Theme.of(context).colorScheme.onErrorContainer;
      statusIcon = Icons.trending_down_rounded;
      statusLabel = 'Below Zero';
    } else if (isZero) {
      // Zero - Neutral/Warning styling
      cardColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      textColor = Theme.of(context).colorScheme.onSurface;
      statusIcon = Icons.remove_circle_outline_rounded;
      statusLabel = 'Empty';
    } else {
      // Positive - Success/Primary styling
      cardColor = Theme.of(context).colorScheme.primaryContainer;
      textColor = Theme.of(context).colorScheme.onPrimaryContainer;
      statusIcon = Icons.account_balance_rounded;
      statusLabel = 'Current Balance';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: textColor.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row with icon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xs),
                decoration: BoxDecoration(
                  color: textColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(statusIcon, size: 16, color: textColor),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                statusLabel,
                style: AppTextStyles.bodySmall.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Info icon hint
              Icon(
                Icons.savings_rounded,
                size: 18,
                color: textColor.withValues(alpha: 0.6),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          // Amount display
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(amount),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableReservationList(
    BuildContext context,
    List<ReserveVO> reservations,
    NumberFormat currencyFormat,
  ) {
    // Show max 4 items initially, then expand to show all
    const maxPreviewItems = 4;
    final needsPagination = reservations.length > maxPreviewItems;
    final displayCount = (_showAllReservations || !needsPagination)
        ? reservations.length
        : maxPreviewItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Reservation list - scrollable when needed
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayCount,
          itemBuilder: (context, index) {
            final reservation = reservations[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < displayCount - 1 ? AppSpacing.sm : 0,
              ),
              child: _buildReservationItem(
                context,
                reservation,
                currencyFormat,
              ),
            );
          },
        ),

        // Show More / Show Less button
        if (needsPagination) ...[
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _showAllReservations = !_showAllReservations;
                });
              },
              icon: Icon(
                _showAllReservations
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
              ),
              label: Text(
                _showAllReservations
                    ? 'Show Less (${reservations.length} items)'
                    : 'Show All (${reservations.length} items)',
                style: AppTextStyles.labelLarge,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context, {
    required String label,
    required double amount,
    required Color color,
    required NumberFormat currencyFormat,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: color)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            currencyFormat.format(amount),
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationItem(
    BuildContext context,
    ReserveVO reservation,
    NumberFormat currencyFormat,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: reservation.type == ReserveType.commitmentTask
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.tertiaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              reservation.type == ReserveType.commitmentTask
                  ? Icons.task
                  : Icons.account_balance,
              size: 16,
              color: reservation.type == ReserveType.commitmentTask
                  ? Theme.of(context).colorScheme.error
                  : Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reservation.description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  reservation.typeLabel,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            currencyFormat.format(reservation.amount),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
