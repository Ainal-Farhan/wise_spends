import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/features/settings/presentation/bloc/backup_restore_bloc.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BackupRestoreBloc>().add(const LoadAllFiles());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
      builder: (context, state) {
        // ✅ Read from state.data — never cast to FilesLoaded / BackupHistoryLoaded.
        final data = state.data;
        final isLoadingFiles = state is LoadingFiles;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FullBackupCard(),
              const SizedBox(height: AppSpacing.lg),
              _StorageOverviewCard(
                storageSize: data.formattedStorageSize,
                fileCount: data.files.length,
                rawBytes: data.totalStorageBytes,
              ),
              const SizedBox(height: AppSpacing.xl),
              _FilesSection(files: data.files, isLoading: isLoadingFiles),
              const SizedBox(height: AppSpacing.xl),
              _ResetDataCard(),
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
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.backup_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Full Backup (Recommended)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Includes database AND all uploaded files',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  'ZIP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Create a complete backup including all uploaded files, images, and '
            'database records. Ideal for migrating to a new device.',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          BlocBuilder<BackupRestoreBloc, BackupRestoreState>(
            builder: (context, state) {
              final isLoading = state is BackupRestoreExportingFull;
              return LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 280;
                  final saveBtn = AppButton.primary(
                    label: isLoading ? 'Creating…' : 'Save Backup',
                    icon: isLoading ? null : Icons.save_outlined,
                    isFullWidth: true,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => context.read<BackupRestoreBloc>().add(
                            const ExportFullBackupWithFiles(share: false),
                          ),
                  );
                  final shareBtn = AppButton.secondary(
                    label: isLoading ? 'Creating…' : 'Share Backup',
                    icon: isLoading ? null : Icons.ios_share_rounded,
                    isFullWidth: true,
                    isLoading: isLoading,
                    onPressed: isLoading
                        ? null
                        : () => context.read<BackupRestoreBloc>().add(
                            const ExportFullBackupWithFiles(share: true),
                          ),
                  );
                  if (isNarrow) {
                    return Column(
                      children: [
                        saveBtn,
                        const SizedBox(height: AppSpacing.sm),
                        shareBtn,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Flexible(child: saveBtn),
                      const SizedBox(width: AppSpacing.md),
                      Flexible(child: shareBtn),
                    ],
                  );
                },
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
  final String storageSize;
  final int fileCount;
  final int rawBytes;

  static const int _softCapBytes = 100 * 1024 * 1024;

  const _StorageOverviewCard({
    required this.storageSize,
    required this.fileCount,
    required this.rawBytes,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = (rawBytes / _softCapBytes).clamp(0.0, 1.0);
    final barColor = fraction >= 0.9
        ? Theme.of(context).colorScheme.error
        : fraction >= 0.7
        ? Theme.of(context).colorScheme.tertiary
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            Theme.of(
              context,
            ).colorScheme.primaryContainer.withValues(alpha: 0.25),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  Icons.storage_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
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
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      storageSize,
                      style: AppTextStyles.h2.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$fileCount file${fileCount != 1 ? 's' : ''}',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (rawBytes > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: barColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${(fraction * 100).round()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: barColor,
                    ),
                  ),
                ),
            ],
          ),
          if (rawBytes > 0) ...[
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: fraction),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Theme.of(context).colorScheme.outline,
                  valueColor: AlwaysStoppedAnimation(barColor),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'of ~100 MB soft cap',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _FilesSection extends StatelessWidget {
  final List<StoredFile> files;
  final bool isLoading;

  const _FilesSection({required this.files, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.folder_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Managed Files',
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
            ),
            if (files.isNotEmpty) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  '${files.length}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            IconButton(
              icon: Icon(Icons.refresh_rounded, size: 18),
              onPressed: () =>
                  context.read<BackupRestoreBloc>().add(const LoadAllFiles()),
              tooltip: 'Refresh',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (isLoading && files.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (files.isEmpty)
          _EmptyFilesList()
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: files.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) => _FileListTile(
              file: files[index],
              onDelete: () => _confirmDeleteFile(context, files[index]),
            ),
          ),
      ],
    );
  }

  void _confirmDeleteFile(BuildContext context, StoredFile file) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: 'Delete File?',
          message:
              'Are you sure you want to delete "${file.originalName}"?\nThis action cannot be undone.',
          icon: Icons.delete_outline_rounded,
          iconColor: Theme.of(context).colorScheme.error,
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
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_outlined,
              size: 48,
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No files managed yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Files you upload in the app will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
    final (iconData, accentColor) = _iconForMimeType(context, file.mimeType);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 3, color: accentColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(iconData, color: accentColor, size: 22),
                      ),
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
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                _CategoryChip(
                                  label: file.category.name,
                                  color: accentColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        color: Theme.of(context).colorScheme.error,
                        onPressed: onDelete,
                        iconSize: 20,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  (IconData, Color) _iconForMimeType(BuildContext context, String mimeType) {
    if (mimeType.startsWith('image/')) {
      return (Icons.image_outlined, Theme.of(context).colorScheme.primary);
    }
    if (mimeType.startsWith('video/')) {
      return (Icons.video_file_outlined, Theme.of(context).colorScheme.secondary);
    }
    if (mimeType.startsWith('audio/')) {
      return (Icons.audio_file_outlined, Theme.of(context).colorScheme.primary);
    }
    if (mimeType.contains('pdf')) {
      return (Icons.picture_as_pdf_outlined, Theme.of(context).colorScheme.secondary);
    }
    if (mimeType.contains('word') || mimeType.contains('document')) {
      return (Icons.description_outlined, Theme.of(context).colorScheme.tertiary);
    }
    if (mimeType.startsWith('text/')) {
      return (
        Icons.description_outlined,
        Theme.of(context).colorScheme.onSurfaceVariant,
      );
    }
    return (
      Icons.insert_drive_file_outlined,
      Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  const _CategoryChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _ResetDataCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Danger Zone',
                  style: AppTextStyles.h3.copyWith(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Permanently delete all data: transactions, budgets, savings plans, '
            'uploaded files, and settings. This action cannot be undone.',
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
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
          iconColor: Theme.of(context).colorScheme.error,
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
