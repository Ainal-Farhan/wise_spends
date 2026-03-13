/// Localization key constants for the Backup & Restore feature.
///
/// Usage:
///   Text(BackupRestoreKeys.title.tr)
///   BackupRestoreKeys.exportSharedSuccess.trWith({'format': 'JSON'})
abstract class BackupRestoreKeys {
  BackupRestoreKeys._();

  // ── Screen ──────────────────────────────────────────────────────────────────
  static const title = 'backup_restore.title';

  // ── Tab labels ───────────────────────────────────────────────────────────────
  static const tabBackup = 'backup_restore.tab.backup';
  static const tabHistory = 'backup_restore.tab.history';

  // ── Hero card ────────────────────────────────────────────────────────────────
  static const heroTitle = 'backup_restore.hero.title';
  static const heroSubtitle = 'backup_restore.hero.subtitle';

  // ── Section labels ────────────────────────────────────────────────────────────
  static const sectionShareTitle = 'backup_restore.section.share.title';
  static const sectionShareSubtitle = 'backup_restore.section.share.subtitle';

  static const sectionSaveTitle = 'backup_restore.section.save.title';
  static const sectionSaveSubtitle = 'backup_restore.section.save.subtitle';

  static const sectionRestoreTitle = 'backup_restore.section.restore.title';
  static const sectionRestoreSubtitle =
      'backup_restore.section.restore.subtitle';

  // ── Format cards ──────────────────────────────────────────────────────────────
  static const formatJsonLabel = 'backup_restore.format.json.label';
  static const formatJsonDesc = 'backup_restore.format.json.desc';
  static const formatSqliteLabel = 'backup_restore.format.sqlite.label';
  static const formatSqliteDesc = 'backup_restore.format.sqlite.desc';

  // ── Restore card ──────────────────────────────────────────────────────────────
  static const restoreCardTitle = 'backup_restore.restore_card.title';
  static const restoreCardSubtitle = 'backup_restore.restore_card.subtitle';

  // ── Auto-backup card ──────────────────────────────────────────────────────────
  static const autoBackupTitle = 'backup_restore.auto_backup.title';
  static const autoBackupSubtitle = 'backup_restore.auto_backup.subtitle';

  // ── Warning card ──────────────────────────────────────────────────────────────
  static const warningText = 'backup_restore.warning.text';

  // ── History empty state ───────────────────────────────────────────────────────
  static const historyEmptyTitle = 'backup_restore.history.empty.title';
  static const historyEmptySubtitle = 'backup_restore.history.empty.subtitle';
  static const historyRefresh = 'backup_restore.history.refresh';

  // ── History tile actions ──────────────────────────────────────────────────────
  static const historyActionRestore = 'backup_restore.history.action.restore';
  static const historyActionShare = 'backup_restore.history.action.share';
  static const historyActionDelete = 'backup_restore.history.action.delete';

  // ── Dialogs ───────────────────────────────────────────────────────────────────
  static const dialogShareTitle = 'backup_restore.dialog.share.title';
  static const dialogShareMessage = 'backup_restore.dialog.share.message';
  static const dialogShareConfirm = 'backup_restore.dialog.share.confirm';

  static const dialogRestoreTitle = 'backup_restore.dialog.restore.title';
  static const dialogRestoreMessage = 'backup_restore.dialog.restore.message';
  static const dialogRestoreConfirm = 'backup_restore.dialog.restore.confirm';

  static const dialogDeleteTitle = 'backup_restore.dialog.delete.title';
  // accepts {name}
  static const dialogDeleteMessage = 'backup_restore.dialog.delete.message';
  static const dialogDeleteConfirm = 'backup_restore.dialog.delete.confirm';

  static const dialogRestoreHistoryTitle =
      'backup_restore.dialog.restore_history.title';
  // accepts {name}
  static const dialogRestoreHistoryMessage =
      'backup_restore.dialog.restore_history.message';

  static const dialogCancel = 'backup_restore.dialog.cancel';

  // ── Snackbars ─────────────────────────────────────────────────────────────────
  // accepts {format}
  static const snackExportSharedSuccess =
      'backup_restore.snack.export_shared_success';
  // accepts {format}
  static const snackExportSavedSuccess =
      'backup_restore.snack.export_saved_success';
  static const snackImportSuccess = 'backup_restore.snack.import_success';
  static const snackShareSuccess = 'backup_restore.snack.share_success';
  static const snackDeleteSuccess = 'backup_restore.snack.delete_success';

  // ── Operation loading ─────────────────────────────────────────────────────────
  // accepts {format}
  static const loadingExporting = 'backup_restore.loading.exporting';
  static const loadingRestoring = 'backup_restore.loading.restoring';
  static const loadingSharing = 'backup_restore.loading.sharing';
  static const loadingDeleting = 'backup_restore.loading.deleting';
  static const loadingProcessing = 'backup_restore.loading.processing';
}
