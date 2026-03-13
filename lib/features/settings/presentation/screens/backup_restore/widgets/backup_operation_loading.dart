import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Full-screen loading view shown while an async backup operation is in progress.
///
/// Adapts its icon and message to the current [BackupRestoreState].
class BackupOperationLoading extends StatelessWidget {
  final BackupRestoreState state;

  const BackupOperationLoading({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final (icon, message) = _resolve(state);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 38, color: AppColors.primary),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.all(Radius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  (IconData, String) _resolve(BackupRestoreState state) => switch (state) {
    BackupRestoreExporting s => (
      Icons.upload_file_rounded,
      BackupRestoreKeys.loadingExporting.trWith({'format': s.format}),
    ),
    BackupRestoreImporting _ => (
      Icons.download_for_offline_outlined,
      BackupRestoreKeys.loadingRestoring.tr,
    ),
    BackupSharingFile _ => (
      Icons.ios_share_rounded,
      BackupRestoreKeys.loadingSharing.tr,
    ),
    BackupDeletingFile _ => (
      Icons.delete_sweep_outlined,
      BackupRestoreKeys.loadingDeleting.tr,
    ),
    _ => (
      Icons.hourglass_empty_rounded,
      BackupRestoreKeys.loadingProcessing.tr,
    ),
  };
}
