import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Centred empty-state shown when a deposits or spending list has no entries.
class TransactionEmpty extends StatelessWidget {
  const TransactionEmpty({
    super.key,
    required this.icon,
    required this.messageKey,
    this.subMessageKey,
  });

  final IconData icon;

  /// Localisation key for the primary message, e.g. `'budget_plans.no_deposits'`.
  final String messageKey;

  /// Optional localisation key for a secondary hint line.
  final String? subMessageKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.xxxl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon in a soft tinted circle
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
              child: Icon(icon, size: 32, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              messageKey.tr,
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subMessageKey != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subMessageKey!.tr,
                style: AppTextStyles.caption.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
