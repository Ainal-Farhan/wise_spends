import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/features/settings/presentation/screens/backup_restore/l10n/backup_restore_key.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';

import 'backup_empty_history.dart';
import 'backup_history_tile.dart';

/// The "History" tab: pull-to-refresh list of local backups.
///
/// Each tile allows the user to restore, share, or delete a backup file.
class HistoryTab extends StatelessWidget {
  final BackupRestoreState state;

  const HistoryTab({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is BackupHistoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final backups = _resolveBackups(state);

    if (backups.isEmpty) {
      return BackupEmptyHistory(
        onRefresh: () =>
            context.read<BackupRestoreBloc>().add(const LoadBackupHistory()),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<BackupRestoreBloc>().add(const LoadBackupHistory()),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: backups.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final backup = backups[index];
          return BackupHistoryTile(
            backup: backup,
            onShare: () => context.read<BackupRestoreBloc>().add(
              ShareExistingBackup(backup.filePath),
            ),
            onDelete: () => _confirmDelete(context, backup),
            onRestore: () => _confirmRestoreFromHistory(context, backup),
          );
        },
      ),
    );
  }

  List<BackupFileInfo> _resolveBackups(BackupRestoreState state) {
    if (state is BackupHistoryLoaded) return state.backups;
    if (state is BackupDeleteSuccess) return state.remainingBackups;
    return [];
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────

  void _confirmDelete(BuildContext context, BackupFileInfo backup) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: BackupRestoreKeys.dialogDeleteTitle.tr,
          message: BackupRestoreKeys.dialogDeleteMessage.trWith({
            'name': backup.fileName,
          }),
          icon: Icons.delete_outline_rounded,
          iconColor: AppColors.error,
          buttons: [
            CustomDialogButton(
              text: BackupRestoreKeys.dialogCancel.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: BackupRestoreKeys.dialogDeleteConfirm.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                context.read<BackupRestoreBloc>().add(
                  DeleteBackupFile(backup.filePath),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestoreFromHistory(BuildContext context, BackupFileInfo backup) {
    showDialog(
      context: context,
      builder: (ctx) => CustomDialog(
        config: CustomDialogConfig(
          title: BackupRestoreKeys.dialogRestoreHistoryTitle.tr,
          message: BackupRestoreKeys.dialogRestoreHistoryMessage.trWith({
            'name': backup.fileName,
          }),
          icon: Icons.warning_amber_rounded,
          iconColor: AppColors.warning,
          buttons: [
            CustomDialogButton(
              text: BackupRestoreKeys.dialogCancel.tr,
              onPressed: () => Navigator.pop(ctx),
            ),
            CustomDialogButton(
              text: BackupRestoreKeys.dialogRestoreConfirm.tr,
              isDestructive: true,
              onPressed: () {
                Navigator.pop(ctx);
                // Restore directly from the known path — no file picker shown.
                context.read<BackupRestoreBloc>().add(
                  RestoreFromPath(backup.filePath),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
