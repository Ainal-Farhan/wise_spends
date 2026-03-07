import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/services/backup_service.dart';
import 'backup_restore_event.dart';
import 'backup_restore_state.dart';

class BackupRestoreBloc extends Bloc<BackupRestoreEvent, BackupRestoreState> {
  final BackupService _backupService;

  BackupRestoreBloc(this._backupService) : super(BackupRestoreInitial()) {
    on<ExportDataToJson>(_onExportToJson);
    on<ExportDataToSqlite>(_onExportToSqlite);
    on<ExportDataToDownloads>(_onExportToDownloads);
    on<ImportDataFromFile>(_onImportFromFile);
  }

  Future<void> _onExportToJson(
    ExportDataToJson event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(const BackupRestoreExporting('JSON'));
      await _backupService.backupAndShare(type: '.json');
      emit(const BackupRestoreExportSuccess('Exported successfully', 'JSON'));
    } catch (e) {
      emit(BackupRestoreExportError('Failed to export: $e'));
    }
  }

  Future<void> _onExportToSqlite(
    ExportDataToSqlite event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(const BackupRestoreExporting('SQLite'));
      await _backupService.backupAndShare(type: '.sqlite');
      emit(const BackupRestoreExportSuccess('Exported successfully', 'SQLite'));
    } catch (e) {
      emit(BackupRestoreExportError('Failed to export: $e'));
    }
  }

  Future<void> _onExportToDownloads(
    ExportDataToDownloads event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreExporting(event.format));
      final filePath = await _backupService.backupToInternalStorageMedia(
        type: event.format == 'JSON' ? '.json' : '.sqlite',
      );
      emit(BackupRestoreExportSuccess(filePath, event.format));
    } catch (e) {
      emit(BackupRestoreExportError('Failed to export: $e'));
    }
  }

  Future<void> _onImportFromFile(
    ImportDataFromFile event,
    Emitter<BackupRestoreState> emit,
  ) async {
    try {
      emit(BackupRestoreImporting());
      final success = await _backupService.restore();
      if (success) {
        emit(BackupRestoreImportSuccess());
      } else {
        emit(const BackupRestoreImportError('Restore failed'));
      }
    } catch (e) {
      emit(BackupRestoreImportError('Failed to restore: $e'));
    }
  }
}
