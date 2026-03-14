import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/settings/presentation/bloc/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Full-screen loading overlay shown while an async backup operation runs.
///
/// Shows an animated icon, step subtitle, and a smooth indeterminate progress
/// bar so the user always knows something is happening.
class BackupOperationLoading extends StatefulWidget {
  final BackupRestoreState state;

  const BackupOperationLoading({super.key, required this.state});

  @override
  State<BackupOperationLoading> createState() => _BackupOperationLoadingState();
}

class _BackupOperationLoadingState extends State<BackupOperationLoading>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle, steps) = _resolve(widget.state);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated icon ring
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RotationTransition(
                      turns: _rotateController,
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.0),
                              Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, size: 38, color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              Text(
                title,
                style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppSpacing.xl),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const SizedBox(
                  width: 180,
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                ),
              ),

              if (steps.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                _StepList(steps: steps),
              ],
            ],
          ),
        ),
      ),
    );
  }

  (IconData, String, String, List<String>) _resolve(BackupRestoreState state) =>
      switch (state) {
        BackupRestoreExporting s => (
          Icons.upload_rounded,
          BackupRestoreKeys.loadingExporting.trWith({'format': s.format}),
          'Compressing your data…',
          ['Reading database', 'Serialising records', 'Writing file'],
        ),
        BackupRestoreExportingFull _ => (
          Icons.backup_rounded,
          'Creating full backup…',
          'Bundling database and all uploaded files into a ZIP archive',
          ['Collecting files', 'Compressing data', 'Packaging archive'],
        ),
        BackupRestoreImporting _ => (
          Icons.download_for_offline_outlined,
          BackupRestoreKeys.loadingRestoring.tr,
          'Importing and applying your backup data…',
          ['Validating file', 'Clearing existing data', 'Restoring records'],
        ),
        BackupSharingFile _ => (
          Icons.ios_share_rounded,
          BackupRestoreKeys.loadingSharing.tr,
          'Opening the share sheet…',
          [],
        ),
        BackupDeletingFile _ => (
          Icons.delete_sweep_outlined,
          BackupRestoreKeys.loadingDeleting.tr,
          'Removing the backup file from device…',
          [],
        ),
        ResettingData _ => (
          Icons.restore_from_trash_rounded,
          'Resetting all data…',
          'This may take a moment. Please do not close the app.',
          [
            'Deleting uploaded files',
            'Clearing database tables',
            'Finalising reset',
          ],
        ),
        LoadingFiles _ => (
          Icons.folder_open_rounded,
          'Loading files…',
          'Scanning managed file storage…',
          [],
        ),
        FileDeleting _ => (
          Icons.delete_outline_rounded,
          'Deleting file…',
          'Removing file from storage…',
          [],
        ),
        _ => (
          Icons.hourglass_empty_rounded,
          BackupRestoreKeys.loadingProcessing.tr,
          'Please wait…',
          [],
        ),
      };
}

class _StepList extends StatelessWidget {
  final List<String> steps;
  const _StepList({required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                step,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
