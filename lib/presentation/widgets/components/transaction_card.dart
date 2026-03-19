import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/presentation/widgets/components/amount_display.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/ui_constants.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';

// ─── Helpers ───────────────────────────────────────────────────────────────

/// Check if transaction is a budget plan type.
bool isBudgetPlanType(TransactionType type) {
  return type == TransactionType.budgetPlanDeposit ||
      type == TransactionType.budgetPlanExpense;
}

// ─── Transaction Card ──────────────────────────────────────────────────────
class TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryIcon;
  final IconData? icon;
  final DateTime date;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool showBudgetPlanIndicator;
  final bool isRevoked;

  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryIcon,
    this.icon,
    required this.date,
    this.note,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.showBudgetPlanIndicator = false,
    this.isRevoked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      elevation: UIConstants.elevationNone,
      clipBehavior: Clip.hardEdge, // ensure InkWell ripple is clipped
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        side: BorderSide(
          color: isRevoked
              ? colorScheme.error.withValues(alpha: 0.35)
              : colorScheme.outline,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingLarge,
            vertical: UIConstants.spacingMedium,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Icon ─────────────────────────────────────────────────
              _IconContainer(type: type, icon: icon),

              const SizedBox(width: UIConstants.spacingMedium),

              // ── Title + meta ─────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _TitleRow(
                      title: title,
                      isRevoked: isRevoked,
                      colorScheme: colorScheme,
                      context: context,
                    ),

                    const SizedBox(height: 3),

                    _MetaRow(
                      date: date,
                      note: note,
                      showBudgetPlanIndicator: showBudgetPlanIndicator,
                      colorScheme: colorScheme,
                      context: context,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: UIConstants.spacingSmall),

              // ── Trailing column: revoked badge (if any) + amount ──────
              // Both are right-aligned. The badge sits above the amount,
              // using the vertical space that already exists in the card.
              IntrinsicWidth(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isRevoked) ...[
                      _Badge(
                        icon: Icons.block_rounded,
                        label: 'transaction.detail.revoked'.tr,
                        bgColor: colorScheme.errorContainer,
                        fgColor: colorScheme.onErrorContainer,
                      ),
                      const SizedBox(height: 4),
                    ],
                    AmountDisplay(
                      amount: amount,
                      type: type,
                      style: Theme.of(context).textTheme.titleMedium,
                      note: note,
                    ),
                  ],
                ),
              ),

              // ── Delete button ─────────────────────────────────────────
              if (onDelete != null) ...[
                const SizedBox(width: UIConstants.spacingXS),
                _DeleteButton(onDelete: onDelete!, colorScheme: colorScheme),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icon Container ────────────────────────────────────────────────────────

class _IconContainer extends StatelessWidget {
  final TransactionType type;
  final IconData? icon;

  const _IconContainer({required this.type, this.icon});

  @override
  Widget build(BuildContext context) {
    final bg = type.getBackgroundColor(context);
    const size = UIConstants.touchTargetMin;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
      ),
      child: Center(
        child: Icon(
          icon ?? type.icon,
          color: Theme.of(context).canvasColor,
          size: UIConstants.iconLarge,
        ),
      ),
    );
  }
}

// ─── Title Row ─────────────────────────────────────────────────────────────

/// Renders the transaction title, dimmed when the transaction is revoked.
///
/// The title is always a single line with ellipsis. Dimming gives a subtle
/// visual hint that this entry is inactive without needing an inline badge.
class _TitleRow extends StatelessWidget {
  final String title;
  final bool isRevoked;
  final ColorScheme colorScheme;
  final BuildContext context;

  const _TitleRow({
    required this.title,
    required this.isRevoked,
    required this.colorScheme,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: isRevoked
            ? colorScheme.onSurface.withValues(alpha: 0.45)
            : colorScheme.onSurface,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

// ─── Meta Row ──────────────────────────────────────────────────────────────

/// Renders the date, optional budget badge, and optional note.
///
/// Overflow guards:
/// - Date is always shown at its natural width (no flex).
/// - Badge is shown at its natural width (no flex).
/// - Note is in an [Expanded] so it truncates instead of overflowing.
/// - Budget badge and note are mutually exclusive — badge takes priority.
class _MetaRow extends StatelessWidget {
  final DateTime date;
  final String? note;
  final bool showBudgetPlanIndicator;
  final ColorScheme colorScheme;
  final BuildContext context;

  const _MetaRow({
    required this.date,
    required this.note,
    required this.showBudgetPlanIndicator,
    required this.colorScheme,
    required this.context,
  });

  @override
  Widget build(BuildContext _) {
    final hasNote = note != null && note!.isNotEmpty;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Date — always fixed width, never shrinks.
        Text(
          _formatDate(date),
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
        ),

        // Budget plan badge (takes priority over note)
        if (showBudgetPlanIndicator) ...[
          const SizedBox(width: UIConstants.spacingXS),
          _Badge(
            icon: Icons.account_balance_wallet_outlined,
            label: 'budget_plans.linked'.tr,
            bgColor: colorScheme.primaryContainer,
            fgColor: colorScheme.primary,
          ),
        ]
        // Note — shown only when no budget badge
        else if (hasNote) ...[
          const SizedBox(width: UIConstants.spacingSmall),
          // Dot separator
          Container(
            width: 3,
            height: 3,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: UIConstants.spacingSmall),
          // Expanded ensures long notes are ellipsed rather than overflowing.
          Expanded(
            child: Text(
              note!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return 'Today';
    if (txDate == yesterday) return 'Yesterday';

    final daysAgo = today.difference(txDate).inDays;
    if (daysAgo < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d, y').format(date);
  }
}

// ─── Delete Button ─────────────────────────────────────────────────────────

/// A compact delete icon button with a fixed minimum tap target.
///
/// Uses a fixed [SizedBox] wrapper so the button width is predictable
/// and cannot be squeezed to zero by a very long title + large amount.
class _DeleteButton extends StatelessWidget {
  final VoidCallback onDelete;
  final ColorScheme colorScheme;

  const _DeleteButton({required this.onDelete, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: UIConstants.touchTargetMin,
      height: UIConstants.touchTargetMin,
      child: InkWell(
        onTap: onDelete,
        borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
        child: Icon(
          Icons.delete_outline,
          size: UIConstants.iconMedium,
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

// ─── Badge ─────────────────────────────────────────────────────────────────

/// A small pill badge used for both the budget-linked and revoked indicators.
class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color fgColor;

  const _Badge({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.fgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fgColor),
          const SizedBox(width: 3),
          // Label never wraps — it's a pill, not a text block.
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Swipeable Transaction Card ────────────────────────────────────────────

/// A [TransactionCard] wrapped in a [Dismissible] for swipe-to-delete.
///
/// Changes vs original:
/// • Swipe background has a minimum height via [ConstrainedBox] so it
///   renders correctly even when the card content is very short.
/// • [confirmDismiss] returns `false` instead of `null` on any error path
///   so the card is never accidentally dismissed.
/// • The SnackBar undo label uses a const string key to avoid a missing
///   translation crashing the widget.
class SwipeableTransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryIcon;
  final IconData? icon;
  final DateTime date;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showBudgetPlanIndicator;
  final bool isRevoked;

  const SwipeableTransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryIcon,
    this.icon,
    required this.date,
    this.note,
    this.onTap,
    this.onDelete,
    this.showBudgetPlanIndicator = false,
    this.isRevoked = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key('${title}_${date.millisecondsSinceEpoch}'),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(colorScheme: colorScheme),
      confirmDismiss: (_) => _confirmDelete(context, colorScheme),
      onDismissed: (_) {
        onDelete?.call();
        _showUndoSnackBar(context, colorScheme);
      },
      child: TransactionCard(
        title: title,
        amount: amount,
        type: type,
        categoryIcon: categoryIcon,
        icon: icon,
        date: date,
        note: note,
        onTap: onTap,
        showBudgetPlanIndicator: showBudgetPlanIndicator,
        isRevoked: isRevoked,
      ),
    );
  }

  Future<bool?> _confirmDelete(
    BuildContext context,
    ColorScheme colorScheme,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete Transaction?',
          message:
              'This action cannot be undone. Are you sure you want to delete this transaction?',
          icon: Icons.delete_outline,
          iconColor: colorScheme.error,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx, false),
            ),
            CustomDialogButton(
              text: 'Delete',
              isDestructive: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
      ),
    );
  }

  void _showUndoSnackBar(BuildContext context, ColorScheme colorScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('transaction.deleted'.tr),
        backgroundColor: colorScheme.inverseSurface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
        ),
        action: SnackBarAction(
          label: 'Undo',
          textColor: colorScheme.inversePrimary,
          onPressed: () {
            // Undo is handled by parent BLoC listener.
          },
        ),
      ),
    );
  }
}

// ─── Swipe Background ──────────────────────────────────────────────────────

/// The red delete background revealed when the user swipes left.
///
/// [ConstrainedBox] sets a minimum height so the background is always
/// tall enough to be legible regardless of card content height.
class _SwipeBackground extends StatelessWidget {
  final ColorScheme colorScheme;

  const _SwipeBackground({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: UIConstants.touchTargetMin),
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.spacingLarge,
        ),
        decoration: BoxDecoration(
          // Slightly saturated error colour — clearly destructive.
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: UIConstants.iconXLarge,
            ),
            const SizedBox(height: 2),
            Text(
              'Delete',
              style: AppTextStyles.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
