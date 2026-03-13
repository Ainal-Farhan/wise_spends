import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/services/backup/backup_service.dart';
import 'package:equatable/equatable.dart';

part 'backup_restore_event.dart';
part 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupService _backupService;

  BackupRestoreBloc(this._backupService) : super(BackupRestoreInitial()) {
    // ── Export ──────────────────────────────────────────────────────────────
    on<ExportDataToShare>(_onExportToShare);
    on<ExportDataToInternalStorage>(_onExportToInternalStorage);

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
  }

  // ─── Export handlers ──────────────────────────────────────────────────────

  Future<void> _onExportToShare(
    ExportDataToShare event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExporting(event.format));
      final type = event.format == 'JSON' ? '.json' : '.sqlite';
      await _backupService.backupAndShare(type: type);
      emit(BackupRestoreExportSuccess('', event.format, shared: true));
    } catch (e) {
      emit(BackupRestoreExportError(_friendlyError(e, 'export')));
    }
  }

  Future<void> _onExportToInternalStorage(
    ExportDataToInternalStorage event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExporting(event.format));
      final type = event.format == 'JSON' ? '.json' : '.sqlite';
      final filePath = await _backupService.backupToInternalStorage(type: type);
      emit(BackupRestoreExportSuccess(filePath, event.format));
    } catch (e) {
      emit(BackupRestoreExportError(_friendlyError(e, 'export')));
    }
  }

  // ─── Import handlers ──────────────────────────────────────────────────────

  Future<void> _onImportFromFile(
    ImportDataFromFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreImporting());
      final success = await _backupService.restore();
      if (success) {
        emit(const BackupRestoreImportSuccess());
      } else {
        emit(
          const BackupRestoreImportError(
            'No file was selected or the file could not be read.',
          ),
        );
      }
    } catch (e) {
      emit(BackupRestoreImportError(_friendlyError(e, 'restore')));
    }
  }

  Future<void> _onRestoreFromPath(
    RestoreFromPath event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreImporting());
      final success = await _backupService.restoreFromPath(event.filePath);
      if (success) {
        emit(const BackupRestoreImportSuccess());
      } else {
        emit(
          const BackupRestoreImportError(
            'Restore failed — file may be corrupt.',
          ),
        );
      }
    } catch (e) {
      emit(BackupRestoreImportError(_friendlyError(e, 'restore')));
    }
  }

  // ─── History handlers ─────────────────────────────────────────────────────

  Future<void> _onLoadHistory(
    LoadBackupHistory event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupHistoryLoading());
      final backups = await _backupService.listBackups();
      final autoEnabled = await _backupService.getAutoBackupEnabled();
      emit(
        BackupHistoryLoaded(backups: backups, autoBackupEnabled: autoEnabled),
      );
    } catch (e) {
      emit(BackupHistoryError(_friendlyError(e, 'load history')));
    }
  }

  Future<void> _onShareExisting(
    ShareExistingBackup event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupSharingFile(event.filePath));
      await _backupService.shareBackupFile(event.filePath);
      emit(BackupShareSuccess());
    } catch (e) {
      emit(BackupShareError(_friendlyError(e, 'share')));
    }
  }

  Future<void> _onDeleteBackup(
    DeleteBackupFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    // Preserve current list so the UI stays populated while the delete runs.
    final currentBackups = state is BackupHistoryLoaded
        ? (state as BackupHistoryLoaded).backups
        : <BackupFileInfo>[];

    try {
      emit(BackupDeletingFile(event.filePath));
      await _backupService.deleteBackupFile(event.filePath);
      final updated = currentBackups
          .where((b) => b.filePath != event.filePath)
          .toList();
      emit(BackupDeleteSuccess(updated));
    } catch (e) {
      emit(BackupDeleteError(_friendlyError(e, 'delete')));
    }
  }

  // ─── Auto-backup handler ──────────────────────────────────────────────────

  Future<void> _onToggleAutoBackup(
    ToggleAutoBackup event,
    Emitter<BackupRestoreState> emit,
  ) async {
    await _backupService.setAutoBackup(event.enabled);
    if (state is BackupHistoryLoaded) {
      emit(
        (state as BackupHistoryLoaded).copyWith(
          autoBackupEnabled: event.enabled,
        ),
      );
    }
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _friendlyError(Object e, String action) {
    final msg = e.toString().replaceFirst('Exception: ', '');
    return 'Failed to $action: $msg';
  }
}
