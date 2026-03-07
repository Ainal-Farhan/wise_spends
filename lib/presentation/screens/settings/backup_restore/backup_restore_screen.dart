import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/data/services/backup_service.dart';
import 'package:wise_spends/presentation/blocs/backup/backup_restore_bloc.dart';
import 'package:wise_spends/presentation/blocs/backup/backup_restore_event.dart';
import 'package:wise_spends/presentation/blocs/backup/backup_restore_state.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Backup & Restore Screen
///
/// Features:
/// - Export data to JSON (share)
/// - Export data to SQLite (share)
/// - Export to internal storage
/// - Restore from file
/// - Loading states and feedback
class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BackupRestoreBloc(BackupService()),
      child: const _BackupRestoreScreenContent(),
    );
  }
}

class _BackupRestoreScreenContent extends StatelessWidget {
  const _BackupRestoreScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('backup_restore.title'.tr),
        centerTitle: true,
      ),
      body: BlocConsumer<BackupRestoreBloc, BackupRestoreState>(
        listener: (context, state) {
          if (state is BackupRestoreExportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Data exported to ${state.format}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          } else if (state is BackupRestoreImportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    const Expanded(
                      child: Text(
                        'Data restored successfully',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          } else if (state is BackupRestoreExportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          } else if (state is BackupRestoreImportError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.white),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BackupRestoreLoading ||
              state is BackupRestoreExporting ||
              state is BackupRestoreImporting) {
            return _buildLoadingState(context, state);
          }

          return _buildContent(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, BackupRestoreState state) {
    String message = 'Processing...';
    IconData icon = Icons.hourglass_empty;

    if (state is BackupRestoreExporting) {
      message = 'Exporting to ${state.format}...';
      icon = Icons.upload_file;
    } else if (state is BackupRestoreImporting) {
      message = 'Restoring data...';
      icon = Icons.download_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction Card
          _buildInfoCard(),
          const SizedBox(height: AppSpacing.xxl),

          // Export Section
          _buildSectionHeader(
            title: 'Export Data',
            subtitle: 'Create a backup of your data',
            icon: Icons.upload_file,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildExportOption(
            context,
            icon: Icons.description,
            title: 'Export to JSON',
            subtitle: 'Shareable format, human-readable',
            color: AppColors.primary,
            onTap: () => _confirmExport(context, 'JSON'),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildExportOption(
            context,
            icon: Icons.storage,
            title: 'Export to SQLite',
            subtitle: 'Database format, faster restore',
            color: AppColors.tertiary,
            onTap: () => _confirmExport(context, 'SQLite'),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildExportOption(
            context,
            icon: Icons.folder,
            title: 'Save to Internal Storage',
            subtitle: 'Save to app backup folder',
            color: AppColors.success,
            onTap: () => _showExportLocationDialog(context),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Import Section
          _buildSectionHeader(
            title: 'Restore Data',
            subtitle: 'Restore from a backup file',
            icon: Icons.download_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),

          _buildImportCard(context),

          const SizedBox(height: AppSpacing.xxl),

          // Warning Card
          _buildWarningCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.backup_outlined,
                  color: Colors.white,
                  size: AppIconSize.md,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Backup & Restore',
                  style: AppTextStyles.h3.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Keep your data safe! Export your data regularly to avoid losing important information.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: AppIconSize.sm,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                icon,
                color: color,
                size: AppIconSize.md,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildImportCard(BuildContext context) {
    return InkWell(
      onTap: () => _confirmRestore(context),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.tertiaryContainer,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.tertiary.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.tertiary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.restore,
                color: AppColors.tertiary,
                size: AppIconSize.md,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Restore from File',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Select a backup file to restore',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
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

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: AppIconSize.md,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Restoring data will replace all existing data. Make sure to backup current data first.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmExport(BuildContext context, String format) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Export Data',
          message: 'Do you want to export your data to $format format?',
          icon: Icons.upload_file,
          iconColor: AppColors.primary,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Export',
              isDefault: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BackupRestoreBloc>().add(
                  ExportDataToDownloads(format),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Export Location',
          message: 'Choose export format for internal storage',
          icon: Icons.folder_outlined,
          iconColor: AppColors.tertiary,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'JSON',
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BackupRestoreBloc>().add(
                  const ExportDataToDownloads('JSON'),
                );
              },
            ),
            CustomDialogButton(
              text: 'SQLite',
              isDefault: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BackupRestoreBloc>().add(
                  const ExportDataToDownloads('SQLite'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Restore Data',
          message:
              'Are you sure you want to restore data? This will replace all existing data. Make sure you have a backup!',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(dialogContext),
            ),
            CustomDialogButton(
              text: 'Restore',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<BackupRestoreBloc>().add(ImportDataFromFile());
              },
            ),
          ],
        ),
      ),
    );
  }
}
