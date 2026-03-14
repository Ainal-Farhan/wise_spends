import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/services/preferences_service.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/common/impl/file_storage_repository.dart';
import 'package:wise_spends/domain/models/backup_file_info.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:wise_spends/features/settings/data/workmanager/backup_task_config.dart';
import 'package:workmanager/workmanager.dart';

/// All backup types the app can produce.
enum BackupFormat {
  /// Plain JSON database export  →  backup_YYYYMMDD_HHmmss.json
  json,

  /// SQLite VACUUM copy          →  backup_YYYYMMDD_HHmmss.sqlite
  sqlite,

  /// ZIP archive (DB export + all uploaded files)
  /// →  backup_YYYYMMDD_HHmmss_full.zip
  fullZip,
}

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final AppDatabase _database = AppDatabase();
  final FileStorageRepository _fileStorage = FileStorageRepository();

  /// Single source of truth for preferences — no raw SharedPreferences here.
  final _prefs = PreferencesService();

  // ── Backup directory ───────────────────────────────────────────────────────

  Future<String> _backupDirPath() => _database.getBackupFolderPath();

  // ── Filename helpers ───────────────────────────────────────────────────────

  String _fileTimestamp() {
    final now = DateTime.now();
    return '${now.year}'
        '${_pad(now.month)}'
        '${_pad(now.day)}'
        '_'
        '${_pad(now.hour)}'
        '${_pad(now.minute)}'
        '${_pad(now.second)}';
  }

  String _displayTimestamp() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  BackupFormat _formatOf(String filePath) {
    if (filePath.endsWith('.zip')) return BackupFormat.fullZip;
    if (filePath.endsWith('.sqlite')) return BackupFormat.sqlite;
    return BackupFormat.json;
  }

  // ── Export & Share ─────────────────────────────────────────────────────────

  Future<void> backupAndShare({String type = '.json'}) async {
    String? filePath;
    try {
      filePath = await _database.exportInto(type);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Wise Spends Backup – ${_displayTimestamp()}',
        ),
      );
    } catch (e) {
      throw Exception('Share backup failed: $e');
    } finally {
      _tryDelete(filePath);
    }
  }

  Future<String> backupToInternalStorage({String type = '.json'}) async {
    try {
      return await _database.exportToInternalStorageMedia(type);
    } catch (e) {
      throw Exception('Internal backup failed: $e');
    }
  }

  // ── Full backup (ZIP) ──────────────────────────────────────────────────────

  Future<String> backupFullWithFiles({bool share = false}) async {
    try {
      final backupDir = await _backupDirPath();
      final zipPath = p.join(backupDir, 'backup_${_fileTimestamp()}_full.zip');

      final result = await _fileStorage.createBackup(destinationPath: zipPath);
      if (result == null) throw Exception('ZIP creation failed');

      if (share) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(zipPath)],
            text: 'Wise Spends Full Backup – ${_displayTimestamp()}',
          ),
        );
      }

      return zipPath;
    } catch (e) {
      throw Exception('Full backup failed: $e');
    }
  }

  // ── Restore ────────────────────────────────────────────────────────────────

  Future<bool> restore() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['zip', 'json', 'sqlite'],
      );
      if (result == null || result.files.isEmpty) return false;
      final filePath = result.files.single.path;
      if (filePath == null) return false;
      return await restoreFromPath(filePath);
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }

  Future<bool> restoreFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found: $filePath');
    }
    try {
      switch (_formatOf(filePath)) {
        case BackupFormat.fullZip:
          return await _fileStorage.restoreFromBackup(filePath);
        case BackupFormat.sqlite:
          return await _database.restoreFromPath(filePath, '.sqlite');
        case BackupFormat.json:
          return await _database.restoreFromPath(filePath, '.json');
      }
    } catch (e) {
      throw Exception('Restore from path failed: $e');
    }
  }

  // ── Backup history ─────────────────────────────────────────────────────────

  Future<List<BackupFileInfo>> listBackups() async {
    try {
      final dir = Directory(await _backupDirPath());
      if (!await dir.exists()) return [];

      final files = dir
          .listSync()
          .whereType<File>()
          .where(
            (f) =>
                f.path.endsWith('.json') ||
                f.path.endsWith('.sqlite') ||
                f.path.endsWith('.zip'),
          )
          .toList();

      final infos = await Future.wait(files.map(_toInfo));
      infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return infos;
    } catch (_) {
      return [];
    }
  }

  Future<void> shareBackupFile(String filePath) async {
    if (!await File(filePath).exists()) {
      throw Exception('Backup file not found');
    }
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: 'Wise Spends Backup – ${p.basename(filePath)}',
      ),
    );
  }

  Future<void> deleteBackupFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  // ── Auto-backup ────────────────────────────────────────────────────────────

  /// Reads auto-backup toggle via [PreferencesService].
  Future<bool> getAutoBackupEnabled() async {
    await _prefs.init();
    return _prefs.getAutoBackupEnabled();
  }

  /// Persists [enabled] via [PreferencesService] and registers/cancels the
  /// Workmanager periodic task accordingly.
  Future<void> setAutoBackup(bool enabled) async {
    await _prefs.init();
    await _prefs.setAutoBackupEnabled(enabled);

    if (enabled) {
      await Workmanager().cancelByUniqueName(BackupTaskConfig.uniqueName);
      await Workmanager().registerPeriodicTask(
        BackupTaskConfig.uniqueName,
        BackupTaskConfig.taskName,
        frequency: BackupTaskConfig.frequency,
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true,
        ),
        backoffPolicy: BackoffPolicy.linear,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } else {
      await Workmanager().cancelByUniqueName(BackupTaskConfig.uniqueName);
    }
  }

  // ── Data reset ─────────────────────────────────────────────────────────────

  Future<bool> resetAllData() async {
    try {
      final activeFiles = await _fileStorage.getAllActiveFiles();
      for (final sf in activeFiles) {
        final f = File(sf.localPath);
        if (await f.exists()) await f.delete();
      }
      await _clearAllDatabaseTables();
      return true;
    } catch (e) {
      throw Exception('Reset data failed: $e');
    }
  }

  Future<void> _clearAllDatabaseTables() async {
    for (final repo
        in SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()) {
      try {
        await repo.deleteAll();
      } catch (_) {}
    }
  }

  // ── File management ────────────────────────────────────────────────────────

  Future<List<StoredFile>> listAllFiles() async {
    try {
      return await _fileStorage.getAllActiveFiles();
    } catch (e) {
      throw Exception('List files failed: $e');
    }
  }

  Future<bool> deleteFile(String fileId) async {
    try {
      return await _fileStorage.deleteFile(fileId);
    } catch (e) {
      throw Exception('Delete file failed: $e');
    }
  }

  Future<int> getTotalStorageUsed() async {
    try {
      return await _fileStorage.getTotalStorageUsed();
    } catch (e) {
      throw Exception('Get storage size failed: $e');
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Future<BackupFileInfo> _toInfo(File file) async {
    final stat = await file.stat();
    return BackupFileInfo(
      filePath: file.path,
      fileName: p.basename(file.path),
      format: _labelOf(file.path),
      sizeBytes: stat.size,
      createdAt: stat.modified,
    );
  }

  String _labelOf(String filePath) {
    if (filePath.endsWith('.zip')) return 'ZIP';
    if (filePath.endsWith('.sqlite')) return 'SQLite';
    return 'JSON';
  }

  void _tryDelete(String? path) {
    if (path == null) return;
    File(path).exists().then((exists) {
      if (exists) File(path).delete().catchError((_) => File(path));
    });
  }
}
