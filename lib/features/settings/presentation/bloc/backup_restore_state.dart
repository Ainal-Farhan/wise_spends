part of 'backup_restore_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Composite data holder
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of ALL async data the backup screen needs.
///
/// Using a single composite object means that loading files never erases the
/// backup history, and vice-versa.  Each async operation updates only the
/// fields it owns and carries the rest forward via [copyWith].
class BackupData extends Equatable {
  final List<BackupFileInfo> backups;
  final List<StoredFile> files;
  final int totalStorageBytes;
  final bool autoBackupEnabled;

  const BackupData({
    this.backups = const [],
    this.files = const [],
    this.totalStorageBytes = 0,
    this.autoBackupEnabled = false,
  });

  BackupData copyWith({
    List<BackupFileInfo>? backups,
    List<StoredFile>? files,
    int? totalStorageBytes,
    bool? autoBackupEnabled,
  }) => BackupData(
    backups: backups ?? this.backups,
    files: files ?? this.files,
    totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
    autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
  );

  String get formattedStorageSize {
    final bytes = totalStorageBytes;
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  List<Object?> get props => [
    backups,
    files,
    totalStorageBytes,
    autoBackupEnabled,
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Base state
// ─────────────────────────────────────────────────────────────────────────────

abstract class BackupRestoreState extends Equatable {
  /// Every state carries the latest known composite data so the UI never
  /// loses context when a loading or success state is emitted.
  final BackupData data;

  const BackupRestoreState({this.data = const BackupData()});

  @override
  List<Object?> get props => [data];
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle / ready
// ─────────────────────────────────────────────────────────────────────────────

class BackupRestoreInitial extends BackupRestoreState {
  const BackupRestoreInitial() : super();
}

/// Emitted after any successful data load — replaces the old
/// [BackupHistoryLoaded] and [FilesLoaded] states.
class BackupRestoreReady extends BackupRestoreState {
  const BackupRestoreReady({required super.data});

  @override
  List<Object?> get props => [data];
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading states  (each carries current data so the UI doesn't blank)
// ─────────────────────────────────────────────────────────────────────────────

class BackupHistoryLoading extends BackupRestoreState {
  const BackupHistoryLoading({super.data});
}

class LoadingFiles extends BackupRestoreState {
  const LoadingFiles({super.data});
}

class BackupRestoreExporting extends BackupRestoreState {
  final String format;
  const BackupRestoreExporting(this.format, {super.data});

  @override
  List<Object?> get props => [format, data];
}

class BackupRestoreExportingFull extends BackupRestoreState {
  const BackupRestoreExportingFull({super.data});
}

class BackupRestoreImporting extends BackupRestoreState {
  const BackupRestoreImporting({super.data});
}

class BackupSharingFile extends BackupRestoreState {
  final String filePath;
  const BackupSharingFile(this.filePath, {super.data});

  @override
  List<Object?> get props => [filePath, data];
}

class BackupDeletingFile extends BackupRestoreState {
  final String filePath;
  const BackupDeletingFile(this.filePath, {super.data});

  @override
  List<Object?> get props => [filePath, data];
}

class ResettingData extends BackupRestoreState {
  const ResettingData({super.data});
}

class FileDeleting extends BackupRestoreState {
  final String fileId;
  const FileDeleting(this.fileId, {super.data});

  @override
  List<Object?> get props => [fileId, data];
}

// ─────────────────────────────────────────────────────────────────────────────
// Success states
// ─────────────────────────────────────────────────────────────────────────────

class BackupRestoreExportSuccess extends BackupRestoreState {
  final String filePath;
  final String format;
  final bool shared;

  const BackupRestoreExportSuccess(
    this.filePath,
    this.format, {
    this.shared = false,
    super.data,
  });

  @override
  List<Object?> get props => [filePath, format, shared, data];
}

class BackupRestoreExportFullSuccess extends BackupRestoreState {
  final String filePath;
  final bool shared;

  const BackupRestoreExportFullSuccess(
    this.filePath, {
    this.shared = false,
    super.data,
  });

  @override
  List<Object?> get props => [filePath, shared, data];
}

class BackupRestoreImportSuccess extends BackupRestoreState {
  const BackupRestoreImportSuccess({super.data});
}

class BackupShareSuccess extends BackupRestoreState {
  const BackupShareSuccess({super.data});
}

class BackupDeleteSuccess extends BackupRestoreState {
  /// Kept for backwards compat — the updated list lives in [data.backups].
  List<BackupFileInfo> get remainingBackups => data.backups;
  const BackupDeleteSuccess({super.data});
}

class ResetDataSuccess extends BackupRestoreState {
  const ResetDataSuccess({super.data});
}

class FileDeleted extends BackupRestoreState {
  final String fileId;
  const FileDeleted(this.fileId, {super.data});

  @override
  List<Object?> get props => [fileId, data];
}

// ─────────────────────────────────────────────────────────────────────────────
// Error states
// ─────────────────────────────────────────────────────────────────────────────

class BackupRestoreExportError extends BackupRestoreState {
  final String message;
  const BackupRestoreExportError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class BackupRestoreExportFullError extends BackupRestoreState {
  final String message;
  const BackupRestoreExportFullError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class BackupRestoreImportError extends BackupRestoreState {
  final String message;
  const BackupRestoreImportError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class BackupShareError extends BackupRestoreState {
  final String message;
  const BackupShareError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class BackupDeleteError extends BackupRestoreState {
  final String message;
  const BackupDeleteError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class BackupHistoryError extends BackupRestoreState {
  final String message;
  const BackupHistoryError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class ResetDataError extends BackupRestoreState {
  final String message;
  const ResetDataError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class FilesError extends BackupRestoreState {
  final String message;
  const FilesError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

class FileDeleteError extends BackupRestoreState {
  final String message;
  const FileDeleteError(this.message, {super.data});

  @override
  List<Object?> get props => [message, data];
}

// ─────────────────────────────────────────────────────────────────────────────
// Removed / legacy aliases (keep compilation green if referenced elsewhere)
// ─────────────────────────────────────────────────────────────────────────────

/// @deprecated  Use [BackupRestoreReady] and read [BackupRestoreState.data].
typedef BackupHistoryLoaded = BackupRestoreReady;

/// @deprecated  Use [BackupRestoreReady] and read [BackupRestoreState.data].
typedef FilesLoaded = BackupRestoreReady;
