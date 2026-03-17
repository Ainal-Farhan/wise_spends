import 'package:flutter/material.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// A tinted icon + title + subtitle card used at the top of commitment forms
/// to give the user context about what the form does.
///
/// Example:
/// ```dart
/// CommitmentInfoCard(
///   icon: Icons.calendar_month,
///   title: 'What is a Commitment?',
///   subtitle: 'Recurring expenses like rent or subscriptions',
/// )
/// ```
class CommitmentInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const CommitmentInfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
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
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.tertiary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodySemiBold),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.caption.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
