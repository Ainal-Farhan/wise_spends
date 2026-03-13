import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// The "Data Management" tab: file management and reset data options.
///
/// Responsibilities:
///   • Display list of all managed files with storage usage
///   • Allow deleting individual files
///   • Provide dangerous "Reset All Data" option
class DataManagementTab extends StatefulWidget {
  const DataManagementTab({super.key});

  @override
  State<DataManagementTab> createState() => _DataManagementTabState();
}

class _DataManagementTabState extends State<DataManagementTab>
    with AutomaticKeepAliveClientMixin<DataManagementTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Full backup option
              _FullBackupCard(),
              const SizedBox(height: AppSpacing.lg),

              // Storage overview card
              _StorageOverviewCard(state: state),
              const SizedBox(height: AppSpacing.xl),

              // Files list section
              _FilesSection(state: state),
              const SizedBox(height: AppSpacing.xl),

              // Danger zone - Reset all data
              _ResetDataCard(),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FullBackupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(
                  Icons.backup_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Full Backup (Recommended)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Includes all data AND files',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Create a complete backup of your data including all uploaded files, images, and database records. This is the recommended option for complete device migration.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
            builder: (context, state) {
              final isLoading = state is BackupRestoreExportingFull;
              return Flexible(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Stack vertically if width is too narrow for side-by-side buttons
                    final isNarrow = constraints.maxWidth < 280;
                    if (isNarrow) {
                      return Column(
                        children: [
                          AppButton.primary(
                            label: isLoading ? 'Creating...' : 'Save Backup',
                            icon: isLoading ? null : Icons.save_outlined,
                            isFullWidth: true,
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<BackupRestoreBloc>().add(
                                      const ExportFullBackupWithFiles(share: false),
                                    ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          AppButton.secondary(
                            label: isLoading ? 'Creating...' : 'Share Backup',
                            icon: isLoading ? null : Icons.ios_share_rounded,
                            isFullWidth: true,
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<BackupRestoreBloc>().add(
                                      const ExportFullBackupWithFiles(share: true),
                                    ),
                          ),
                        ],
                      );
                    }
                    return Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: AppButton.primary(
                            label: isLoading ? 'Creating...' : 'Save Backup',
                            icon: isLoading ? null : Icons.save_outlined,
                            isFullWidth: true,
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<BackupRestoreBloc>().add(
                                      const ExportFullBackupWithFiles(share: false),
                                    ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Flexible(
                          flex: 1,
                          child: AppButton.secondary(
                            label: isLoading ? 'Creating...' : 'Share Backup',
                            icon: isLoading ? null : Icons.ios_share_rounded,
                            isFullWidth: true,
                            isLoading: isLoading,
                            onPressed: isLoading
                                ? null
                                : () => context.read<BackupRestoreBloc>().add(
                                      const ExportFullBackupWithFiles(share: true),
                                    ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _StorageOverviewCard extends StatelessWidget {
  final BackupRestoreState state;

  const _StorageOverviewCard({required this.state});

  @override
  Widget build(BuildContext context) {
    final storageSize = _resolveStorageSize(state);
    final fileCount = _resolveFileCount(state);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.storage_rounded,
              color: AppColors.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Storage Used',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  storageSize,
                  style: AppTextStyles.h2.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$fileCount file${fileCount != 1 ? 's' : ''}',
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

  String _resolveStorageSize(BackupRestoreState state) {
    if (state is FilesLoaded) return state.formattedStorageSize;
    return '0 B';
  }

  int _resolveFileCount(BackupRestoreState state) {
    if (state is FilesLoaded) return state.files.length;
    return 0;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilesSection extends StatelessWidget {
  final BackupRestoreState state;

  const _FilesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Managed Files',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: () =>
                  context.read<BackupRestoreBloc>().add(const LoadAllFiles()),
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _buildFileList(context),
      ],
    );
  }

  Widget _buildFileList(BuildContext context) {
    if (state is LoadingFiles) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final files = _resolveFiles(state);

    if (files.isEmpty) {
      return _EmptyFilesList();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: files.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final file = files[index];
        return _FileListTile(
          file: file,
          onDelete: () => _confirmDeleteFile(context, file),
        );
      },
    );
  }

  List<StoredFile> _resolveFiles(BackupRestoreState state) {
    if (state is FilesLoaded) return state.files;
    return [];
  }

  void _confirmDeleteFile(BuildContext context, StoredFile file) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete File?',
          message:
              'Are you sure you want to delete "${file.originalName}"? This action cannot be undone.',
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.error,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: 'Delete',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BackupRestoreBloc>().add(DeleteFile(file.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _EmptyFilesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 48,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No files managed yet',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Files you upload will appear here',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FileListTile extends StatelessWidget {
  final StoredFile file;
  final VoidCallback onDelete;

  const _FileListTile({required this.file, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          _FileIcon(mimeType: file.mimeType),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.originalName,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Text(
                      _formatFileSize(file.sizeBytes),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        file.category.name.toUpperCase(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            onPressed: onDelete,
            tooltip: 'Delete file',
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FileIcon extends StatelessWidget {
  final String mimeType;

  const _FileIcon({required this.mimeType});

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForMimeType(mimeType);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Icon(iconData, color: AppColors.primary, size: 24),
    );
  }

  IconData _getIconForMimeType(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_outlined;
    if (mimeType.startsWith('video/')) return Icons.video_file_outlined;
    if (mimeType.startsWith('audio/')) return Icons.audio_file_outlined;
    if (mimeType.startsWith('text/')) return Icons.description_outlined;
    if (mimeType.contains('pdf')) return Icons.picture_as_pdf_outlined;
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return Icons.description_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResetDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Danger Zone',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Reset all application data including database records and uploaded files. This action is irreversible!',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.secondary(
            label: 'Reset All Data',
            icon: Icons.delete_forever_outlined,
            isFullWidth: true,
            onPressed: () => _confirmResetAllData(context),
          ),
        ],
      ),
    );
  }

  void _confirmResetAllData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Reset All Data?',
          message:
              'This will permanently delete all your data including:\n\n'
              '• All transactions and budgets\n'
              '• All savings plans\n'
              '• All uploaded files and images\n'
              '• All settings and preferences\n\n'
              'This action CANNOT be undone!',
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.error,
          buttons: [
            CustomDialogButton(
              text: 'Cancel',
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: 'Reset Everything',
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BackupRestoreBloc>().add(const ResetAllData());
              },
            ),
          ],
        ),
      ),
    );
  }
}
