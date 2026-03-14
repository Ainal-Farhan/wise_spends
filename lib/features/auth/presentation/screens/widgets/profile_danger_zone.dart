import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// "Danger Zone" card with account deletion confirmation dialog.
class ProfileDangerZone extends StatelessWidget {
  const ProfileDangerZone({super.key, required this.onDeleteAccount});

  /// Called when the user confirms account deletion.
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DangerZoneHeader(),
          const SizedBox(height: AppSpacing.md),
          Text(
            'profile.danger_zone_desc'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.destructive(
            label: 'profile.delete_account'.tr,
            isFullWidth: true,
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'profile.delete_account'.tr,
          message: 'profile.delete_account_confirm'.tr,
          icon: Icons.warning_amber_rounded,
          iconColor: Theme.of(context).colorScheme.secondary,
          buttons: [
            CustomDialogButton(
              text: 'general.cancel'.tr,
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'profile.delete_account'.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                onDeleteAccount();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DangerZoneHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.warning_amber_rounded,
          color: Theme.of(context).colorScheme.secondary,
          size: AppIconSize.md,
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          'profile.danger_zone'.tr,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
