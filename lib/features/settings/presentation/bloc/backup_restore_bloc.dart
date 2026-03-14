import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/models/backup_file_info.dart';
import 'package:wise_spends/features/settings/data/services/backup_service.dart';
import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/models/stored_file.dart';

part 'backup_restore_event.dart';
part 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupService _backupService;

  BackupRestoreBloc(this._backupService) : super(const BackupRestoreInitial()) {
    // ── Export ──────────────────────────────────────────────────────────────
    on<ExportDataToShare>(_onExportToShare);
    on<ExportDataToInternalStorage>(_onExportToInternalStorage);
    on<ExportFullBackupWithFiles>(_onExportFullBackupWithFiles);

    // ── Legacy events ────────────────────────────────────────────────────────
    on<ExportDataToJson>(
      (e, emit) => _onExportToShare(const ExportDataToShare('JSON'), emit),
    );
    on<ExportDataToSqlite>(
      (e, emit) => _onExportToShare(const ExportDataToShare('SQLite'), emit),
    );
    on<ExportDataToDownloads>(
      (e, emit) => _onExportToInternalStorage(
        ExportDataToInternalStorage(e.format),
        emit,
      ),
    );

    // ── Import ───────────────────────────────────────────────────────────────
    on<ImportDataFromFile>(_onImportFromFile);
    on<RestoreFromPath>(_onRestoreFromPath);

    // ── History ──────────────────────────────────────────────────────────────
    on<LoadBackupHistory>(_onLoadHistory);
    on<ShareExistingBackup>(_onShareExisting);
    on<DeleteBackupFile>(_onDeleteBackup);

    // ── Auto-backup ──────────────────────────────────────────────────────────
    on<ToggleAutoBackup>(_onToggleAutoBackup);

    // ── Reset Data ───────────────────────────────────────────────────────────
    on<ResetAllData>(_onResetAllData);

    // ── File Management ──────────────────────────────────────────────────────
    on<LoadAllFiles>(_onLoadAllFiles);
    on<DeleteFile>(_onDeleteFile);
  }

  // ── Convenience getter ────────────────────────────────────────────────────

  /// The latest composite data, regardless of which state is current.
  BackupData get _data => state.data;

  // ─── Export handlers ──────────────────────────────────────────────────────

  Future<void> _onExportToShare(
    ExportDataToShare event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExporting(event.format, data: _data));
      final type = event.format == 'JSON' ? '.json' : '.sqlite';
      await _backupService.backupAndShare(type: type);
      emit(
        BackupRestoreExportSuccess('', event.format, shared: true, data: _data),
      );
    } catch (e) {
      emit(BackupRestoreExportError(_friendlyError(e, 'export'), data: _data));
    }
  }

  Future<void> _onExportToInternalStorage(
    ExportDataToInternalStorage event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExporting(event.format, data: _data));
      final type = event.format == 'JSON' ? '.json' : '.sqlite';
      final filePath = await _backupService.backupToInternalStorage(type: type);
      emit(BackupRestoreExportSuccess(filePath, event.format, data: _data));
    } catch (e) {
      emit(BackupRestoreExportError(_friendlyError(e, 'export'), data: _data));
    }
  }

  Future<void> _onExportFullBackupWithFiles(
    ExportFullBackupWithFiles event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExportingFull(data: _data));
      final filePath = await _backupService.backupFullWithFiles(
        share: event.share,
      );
      emit(
        BackupRestoreExportFullSuccess(
          filePath,
          shared: event.share,
          data: _data,
        ),
      );
    } catch (e) {
      emit(
        BackupRestoreExportFullError(
          _friendlyError(e, 'full backup'),
          data: _data,
        ),
      );
    }
  }

  // ─── Import handlers ──────────────────────────────────────────────────────

  Future<void> _onImportFromFile(
    ImportDataFromFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreImporting(data: _data));
      final success = await _backupService.restore();
      if (success) {
        emit(BackupRestoreImportSuccess(data: _data));
      } else {
        emit(
          const BackupRestoreImportError(
            'No file was selected or the file could not be read.',
          ),
        );
      }
    } catch (e) {
      emit(BackupRestoreImportError(_friendlyError(e, 'restore'), data: _data));
    }
  }

  Future<void> _onRestoreFromPath(
    RestoreFromPath event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreImporting(data: _data));
      final success = await _backupService.restoreFromPath(event.filePath);
      if (success) {
        emit(BackupRestoreImportSuccess(data: _data));
      } else {
        emit(
          const BackupRestoreImportError(
            'Restore failed — file may be corrupt.',
          ),
        );
      }
    } catch (e) {
      emit(BackupRestoreImportError(_friendlyError(e, 'restore'), data: _data));
    }
  }

  // ─── History handlers ─────────────────────────────────────────────────────

  Future<void> _onLoadHistory(
    LoadBackupHistory event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      // Pass current data so the files section doesn't blank while history loads.
      emit(BackupHistoryLoading(data: _data));

      final backups = await _backupService.listBackups();
      final autoEnabled = await _backupService.getAutoBackupEnabled();

      // Merge into existing data — files stay intact.
      final updated = _data.copyWith(
        backups: backups,
        autoBackupEnabled: autoEnabled,
      );
      emit(BackupRestoreReady(data: updated));
    } catch (e) {
      emit(BackupHistoryError(_friendlyError(e, 'load history'), data: _data));
    }
  }

  Future<void> _onShareExisting(
    ShareExistingBackup event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupSharingFile(event.filePath, data: _data));
      await _backupService.shareBackupFile(event.filePath);
      emit(BackupShareSuccess(data: _data));
    } catch (e) {
      emit(BackupShareError(_friendlyError(e, 'share'), data: _data));
    }
  }

  Future<void> _onDeleteBackup(
    DeleteBackupFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupDeletingFile(event.filePath, data: _data));
      await _backupService.deleteBackupFile(event.filePath);

      // Remove from the list in-place; files remain untouched.
      final updatedBackups = _data.backups
          .where((b) => b.filePath != event.filePath)
          .toList();
      final updated = _data.copyWith(backups: updatedBackups);
      emit(BackupDeleteSuccess(data: updated));
    } catch (e) {
      emit(BackupDeleteError(_friendlyError(e, 'delete'), data: _data));
    }
  }

  // ─── Auto-backup handler ──────────────────────────────────────────────────

  Future<void> _onToggleAutoBackup(
    ToggleAutoBackup event,
    Emitter<BackupRestoreState> emit,
  ) async {
    await _backupService.setAutoBackup(event.enabled);
    final updated = _data.copyWith(autoBackupEnabled: event.enabled);
    emit(BackupRestoreReady(data: updated));
  }

  // ─── Reset Data handler ───────────────────────────────────────────────────

  Future<void> _onResetAllData(
    ResetAllData event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(ResettingData(data: _data));
      final success = await _backupService.resetAllData();
      if (success) {
        // Wipe composite data back to empty after a full reset.
        emit(const ResetDataSuccess(data: BackupData()));
      } else {
        emit(ResetDataError('Failed to reset data', data: _data));
      }
    } catch (e) {
      emit(ResetDataError(_friendlyError(e, 'reset data'), data: _data));
    }
  }

  // ─── File Management handlers ─────────────────────────────────────────────

  Future<void> _onLoadAllFiles(
    LoadAllFiles event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      // Pass current data so the history section doesn't blank while files load.
      emit(LoadingFiles(data: _data));

      final files = await _backupService.listAllFiles();
      final totalStorage = await _backupService.getTotalStorageUsed();

      // Merge into existing data — backups stay intact.
      final updated = _data.copyWith(
        files: files,
        totalStorageBytes: totalStorage,
      );
      emit(BackupRestoreReady(data: updated));
    } catch (e) {
      emit(FilesError(_friendlyError(e, 'load files'), data: _data));
    }
  }

  Future<void> _onDeleteFile(
    DeleteFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(FileDeleting(event.fileId, data: _data));
      final success = await _backupService.deleteFile(event.fileId);
      if (success) {
        // Optimistically remove from list; then reload for accurate storage size.
        final updatedFiles = _data.files
            .where((f) => f.id != event.fileId)
            .toList();
        final optimistic = _data.copyWith(files: updatedFiles);
        emit(FileDeleted(event.fileId, data: optimistic));
        // Full reload to get the corrected totalStorageBytes.
        add(const LoadAllFiles());
      } else {
        emit(FileDeleteError('Failed to delete file', data: _data));
      }
    } catch (e) {
      emit(FileDeleteError(_friendlyError(e, 'delete file'), data: _data));
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _friendlyError(Object e, String action) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    return 'Failed to $action: $msg';
  }
}
