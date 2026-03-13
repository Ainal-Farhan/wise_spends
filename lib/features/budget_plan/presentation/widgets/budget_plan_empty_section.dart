import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Empty section widget for milestones and other sections
class EmptySection extends StatelessWidget {
  final IconData icon;
  final String messageKey;

  const EmptySection({super.key, required this.icon, required this.messageKey});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
      child: Row(
        children: [
          Icon(icon, color: WiseSpendsColors.textSecondary, size: 48),
          const SizedBox(width: AppSpacing.md),
          Text(
            messageKey.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: WiseSpendsColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
