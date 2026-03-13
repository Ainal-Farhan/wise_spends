part of 'backup_restore_bloc.dart';

abstract class BackupRestoreEvent extends Equatable {
  const BackupRestoreEvent();

  @override
  List<Object?> get props => [];
}

// ─── Export Events ────────────────────────────────────────────────────────────

/// Export data and open the system share sheet
class ExportDataToShare extends BackupRestoreEvent {
  final String format; // 'JSON' | 'SQLite'
  const ExportDataToShare(this.format);

  @override
  List<Object?> get props => [format];
}

/// Export data silently to the app's internal backup folder
class ExportDataToInternalStorage extends BackupRestoreEvent {
  final String format; // 'JSON' | 'SQLite'
  const ExportDataToInternalStorage(this.format);

  @override
  List<Object?> get props => [format];
}

// ─── Import Events ────────────────────────────────────────────────────────────

/// Let the user pick a backup file and restore from it.
class ImportDataFromFile extends BackupRestoreEvent {
  const ImportDataFromFile();
}

/// Restore directly from a known [filePath] (e.g. tapped from History tab).
/// No file picker is shown — the path is used directly.
class RestoreFromPath extends BackupRestoreEvent {
  final String filePath;
  const RestoreFromPath(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// ─── Backup History Events ────────────────────────────────────────────────────

/// Load the list of backups stored in internal storage
class LoadBackupHistory extends BackupRestoreEvent {
  const LoadBackupHistory();
}

/// Share an existing backup file from history
class ShareExistingBackup extends BackupRestoreEvent {
  final String filePath;
  const ShareExistingBackup(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Delete a backup file from internal storage
class DeleteBackupFile extends BackupRestoreEvent {
  final String filePath;
  const DeleteBackupFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

// ─── Auto-Backup Events ───────────────────────────────────────────────────────

/// Toggle the auto-backup preference
class ToggleAutoBackup extends BackupRestoreEvent {
  final bool enabled;
  const ToggleAutoBackup(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

// ─── Legacy aliases (keep backward compat) ───────────────────────────────────

class ExportDataToJson extends BackupRestoreEvent {}

class ExportDataToSqlite extends BackupRestoreEvent {}

/// @deprecated Use [ExportDataToShare] or [ExportDataToInternalStorage]
class ExportDataToDownloads extends BackupRestoreEvent {
  final String format;
  const ExportDataToDownloads(this.format);

  @override
  List<Object?> get props => [format];
}
