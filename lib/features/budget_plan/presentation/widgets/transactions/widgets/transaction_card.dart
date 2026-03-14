import 'package:flutter/material.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/helpers/transaction_card_config.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/helpers/transaction_dialogs.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/transactions/widgets/delete_slide_background.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A single card layout shared by both deposits and spending entries.
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.config,
    required this.dismissibleKey,
    required this.title,
    required this.subtitle,
    this.note,
    this.badge,
    required this.onTap,
    required this.context,
  });

  /// All type-specific values (color, icon, amount, onDelete, etc.).
  final TransactionCardConfig config;

  /// Unique key passed to [Dismissible] — must differ per item in the list.
  final Key dismissibleKey;

  final String title;
  final String subtitle;

  /// Optional italic third line, e.g. a deposit note.
  final String? note;

  /// Optional trailing badge widget, e.g. a receipt icon pill.
  final Widget? badge;

  final VoidCallback onTap;

  /// Passed through for [confirmDelete] — avoids threading BuildContext
  /// through the config while keeping the config free of Flutter dependencies.
  final BuildContext context;

  @override
  Widget build(BuildContext buildContext) {
    return Dismissible(
      key: dismissibleKey,
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) =>
          confirmDelete(buildContext, messageKey: config.deleteConfirmKey),
      onDismissed: (_) => config.onDelete(),
      background: const DeleteSlideBackground(),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                _LeadingIcon(icon: config.icon, color: config.accentColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _DetailsColumn(
                    title: title,
                    subtitle: subtitle,
                    note: note,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _TrailingColumn(
                  amountLabel: config.amountLabel,
                  amountColor: config.accentColor,
                  badge: badge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Private sub-widgets ───────────────────────────────────────────────────────

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, color: color, size: AppIconSize.md),
    );
  }
}

class _DetailsColumn extends StatelessWidget {
  const _DetailsColumn({
    required this.title,
    required this.subtitle,
    this.note,
  });

  final String title;
  final String subtitle;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTextStyles.caption.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (note != null && note!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            note!,
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _TrailingColumn extends StatelessWidget {
  const _TrailingColumn({
    required this.amountLabel,
    required this.amountColor,
    this.badge,
  });

  final String amountLabel;
  final Color amountColor;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          amountLabel,
          style: AppTextStyles.bodySemiBold.copyWith(color: amountColor),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (badge != null) ...[badge!, const SizedBox(width: 6)],
          ],
        ),
      ],
    );
  }
}
