part of 'backup_restore_bloc.dart';

// ─── Value Objects ────────────────────────────────────────────────────────────

/// Metadata for a single backup file stored in internal storage
class BackupFileInfo extends Equatable {
  final String filePath;
  final String fileName;
  final String format; // 'JSON' | 'SQLite'
  final int sizeBytes;
  final DateTime createdAt;

  const BackupFileInfo({
    required this.filePath,
    required this.fileName,
    required this.format,
    required this.sizeBytes,
    required this.createdAt,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [filePath, fileName, format, sizeBytes, createdAt];
}

// ─── States ───────────────────────────────────────────────────────────────────

abstract class BackupRestoreState extends Equatable {
  const BackupRestoreState();

  @override
  List<Object?> get props => [];
}

class BackupRestoreInitial extends BackupRestoreState {}

class BackupRestoreLoading extends BackupRestoreState {}

// ── Export ──

class BackupRestoreExporting extends BackupRestoreState {
  final String format;
  const BackupRestoreExporting(this.format);

  @override
  List<Object?> get props => [format];
}

class BackupRestoreExportSuccess extends BackupRestoreState {
  final String filePath;
  final String format;

  /// true when the system share sheet was opened (share flow)
  final bool shared;

  const BackupRestoreExportSuccess(
    this.filePath,
    this.format, {
    this.shared = false,
  });

  @override
  List<Object?> get props => [filePath, format, shared];
}

class BackupRestoreExportError extends BackupRestoreState {
  final String message;
  const BackupRestoreExportError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Import ──

class BackupRestoreImporting extends BackupRestoreState {}

class BackupRestoreImportSuccess extends BackupRestoreState {
  const BackupRestoreImportSuccess();
}

class BackupRestoreImportError extends BackupRestoreState {
  final String message;
  const BackupRestoreImportError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── History ──

class BackupHistoryLoading extends BackupRestoreState {}

class BackupHistoryLoaded extends BackupRestoreState {
  final List<BackupFileInfo> backups;
  final bool autoBackupEnabled;

  const BackupHistoryLoaded({
    required this.backups,
    this.autoBackupEnabled = false,
  });

  BackupHistoryLoaded copyWith({
    List<BackupFileInfo>? backups,
    bool? autoBackupEnabled,
  }) => BackupHistoryLoaded(
    backups: backups ?? this.backups,
    autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
  );

  @override
  List<Object?> get props => [backups, autoBackupEnabled];
}

class BackupHistoryError extends BackupRestoreState {
  final String message;
  const BackupHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Share existing ──

class BackupSharingFile extends BackupRestoreState {
  final String filePath;
  const BackupSharingFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class BackupShareSuccess extends BackupRestoreState {}

class BackupShareError extends BackupRestoreState {
  final String message;
  const BackupShareError(this.message);

  @override
  List<Object?> get props => [message];
}

// ── Delete ──

class BackupDeletingFile extends BackupRestoreState {
  final String filePath;
  const BackupDeletingFile(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class BackupDeleteSuccess extends BackupRestoreState {
  final List<BackupFileInfo> remainingBackups;
  const BackupDeleteSuccess(this.remainingBackups);

  @override
  List<Object?> get props => [remainingBackups];
}

class BackupDeleteError extends BackupRestoreState {
  final String message;
  const BackupDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
