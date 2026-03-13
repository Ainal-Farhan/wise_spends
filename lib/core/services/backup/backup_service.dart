import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/core/services/backup/workmanager/backup_task_config.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/common/impl/file_storage_repository.dart';
import 'package:wise_spends/domain/models/stored_file.dart';
import 'package:workmanager/workmanager.dart';

/// SharedPreferences key for the auto-backup toggle.
const _kAutoBackupKey = 'backup_auto_enabled';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final AppDatabase _database = AppDatabase();
  final FileStorageRepository _fileStorage = FileStorageRepository();

  // ─── Export & Share ──────────────────────────────────────────────────────

  /// Export data to a temporary file, open the system share sheet, then
  /// clean up the temp file regardless of the outcome.
  Future<void> backupAndShare({String type = '.json'}) async {
    String? filePath;
    try {
      filePath = await _database.exportInto(type);
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          text: 'Wise Spends Backup – ${_timestamp()}',
        ),
      );
    } catch (e) {
      throw Exception('Share backup failed: $e');
    } finally {
      _tryDelete(filePath);
    }
  }

  /// Create a full backup including all files and data as a ZIP archive.
  /// Returns the path to the created ZIP file.
  Future<String> backupFullWithFiles({bool share = false}) async {
    try {
      // Create ZIP backup with all files and DB manifest
      final zipPath = await _fileStorage.createBackup();
      if (zipPath == null) {
        throw Exception('Failed to create full backup');
      }

      if (share) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(zipPath)],
            text: 'Wise Spends Full Backup (with files) – ${_timestamp()}',
          ),
        );
        // Don't delete the file if sharing - let the system handle it
        return zipPath;
      }

      return zipPath;
    } catch (e) {
      throw Exception('Full backup failed: $e');
    }
  }

  /// Export data silently to the app's internal backup folder.
  /// Returns the saved file path.
  Future<String> backupToInternalStorage({String type = '.json'}) async {
    try {
      return await _database.exportToInternalStorageMedia(type);
    } catch (e) {
      throw Exception('Internal backup failed: $e');
    }
  }

  // ─── Restore ─────────────────────────────────────────────────────────────

  /// Opens the system file picker and restores from whatever the user selects.
  /// Supports JSON, SQLite, and ZIP (full backup with files) formats.
  /// Returns `true` on success, `false` when the user cancels.
  Future<bool> restore() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.custom,
        allowedExtensions: ['zip', 'json', 'sqlite'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final filePath = result.files.single.path;
      if (filePath == null) {
        return false;
      }

      return await restoreFromPath(filePath);
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }

  /// Restores directly from [filePath] without showing a file picker.
  /// File type is inferred from the extension (.json / .sqlite / .zip).
  /// ZIP files contain full backups including uploaded files.
  Future<bool> restoreFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found: $filePath');
    }
    try {
      if (filePath.endsWith('.zip')) {
        // Restore from ZIP archive (includes files)
        return await _fileStorage.restoreFromBackup(filePath);
      } else {
        // Restore from JSON or SQLite
        final type = filePath.endsWith('.sqlite') ? '.sqlite' : '.json';
        return await _database.restoreFromPath(filePath, type);
      }
    } catch (e) {
      throw Exception('Restore from path failed: $e');
    }
  }

  // ─── Backup History ──────────────────────────────────────────────────────

  /// Returns metadata for all backup files in the app's backup folder,
  /// sorted newest-first.
  Future<List<BackupFileInfo>> listBackups() async {
    try {
      final dirPath = await _database.getBackupFolderPath();
      final dir = Directory(dirPath);
      if (!await dir.exists()) return [];

      final files = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json') || f.path.endsWith('.sqlite'))
          .toList();

      final infos = await Future.wait(files.map(_toInfo));
      infos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return infos;
    } catch (_) {
      return [];
    }
  }

  /// Shares an existing backup file via the system share sheet.
  Future<void> shareBackupFile(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) throw Exception('Backup file not found');
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(filePath)],
        text: 'Wise Spends Backup – ${p.basename(filePath)}',
      ),
    );
  }

  /// Permanently removes a backup file from the device.
  Future<void> deleteBackupFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) await file.delete();
  }

  // ─── Auto-Backup Preference ──────────────────────────────────────────────

  /// Returns the persisted auto-backup setting (defaults to `false`).
  Future<bool> getAutoBackupEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAutoBackupKey) ?? false;
  }

  /// Persists [enabled] and registers or cancels the Workmanager periodic task.
  ///
  /// When [enabled] is `true`:
  ///   • Cancels any previous registration first (idempotent).
  ///   • Registers a new weekly periodic task using [BackupTaskConfig].
  ///   • [existingWorkPolicy] is set to [ExistingWorkPolicy.replace] so
  ///     toggling off → on always resets the schedule cleanly.
  ///
  /// When [enabled] is `false`:
  ///   • Cancels the periodic task by its unique name.
  ///   • Any backup that is already in-flight will still complete.
  Future<void> setAutoBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoBackupKey, enabled);

    if (enabled) {
      // Cancel first so re-enabling always resets the interval cleanly.
      await Workmanager().cancelByUniqueName(BackupTaskConfig.uniqueName);

      await Workmanager().registerPeriodicTask(
        BackupTaskConfig.uniqueName,
        BackupTaskConfig.taskName,
        frequency: BackupTaskConfig.frequency,
        // Run on any network condition — backup is local-only.
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: true,
        ),
        // If the device misses the window, run as soon as possible after.
        backoffPolicy: BackoffPolicy.linear,
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
      );
    } else {
      await Workmanager().cancelByUniqueName(BackupTaskConfig.uniqueName);
    }
  }

  // ─── Reset Data ────────────────────────────────────────────────────────────

  /// Resets all application data by clearing all tables and deleting all files.
  /// This is irreversible! Returns true on success.
  Future<bool> resetAllData() async {
    try {
      // First, get all active files and delete them physically
      final activeFiles = await _fileStorage.getAllActiveFiles();

      // Delete all physical files
      for (final file in activeFiles) {
        final fileEntity = File(file.localPath);
        if (await fileEntity.exists()) {
          await fileEntity.delete();
        }
      }

      // Clear all database tables
      await _clearAllDatabaseTables();

      return true;
    } catch (e) {
      throw Exception('Reset data failed: $e');
    }
  }

  /// Clears all data from all database tables
  Future<void> _clearAllDatabaseTables() async {
    // Clear all tables through repositories
    for (final repo
        in SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()) {
      try {
        await repo.deleteAll();
      } catch (e) {
        // Continue with other tables even if one fails
      }
    }
  }

  // ─── File Management ───────────────────────────────────────────────────────

  /// Lists all files managed by the app
  Future<List<StoredFile>> listAllFiles() async {
    try {
      return await _fileStorage.getAllActiveFiles();
    } catch (e) {
      throw Exception('List files failed: $e');
    }
  }

  /// Deletes a file by its ID
  Future<bool> deleteFile(String fileId) async {
    try {
      return await _fileStorage.deleteFile(fileId);
    } catch (e) {
      throw Exception('Delete file failed: $e');
    }
  }

  /// Gets total storage used by all files
  Future<int> getTotalStorageUsed() async {
    try {
      return await _fileStorage.getTotalStorageUsed();
    } catch (e) {
      throw Exception('Get storage size failed: $e');
    }
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Future<BackupFileInfo> _toInfo(File file) async {
    final stat = await file.stat();
    final name = p.basename(file.path);
    final format = file.path.endsWith('.json') ? 'JSON' : 'SQLite';
    return BackupFileInfo(
      filePath: file.path,
      fileName: name,
      format: format,
      sizeBytes: stat.size,
      createdAt: stat.modified,
    );
  }

  String _timestamp() {
    final now = DateTime.now();
    return '${now.year}-${_pad(now.month)}-${_pad(now.day)} '
        '${_pad(now.hour)}:${_pad(now.minute)}';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  void _tryDelete(String? path) {
    if (path == null) return;
    File(path).exists().then((exists) {
      if (exists) File(path).delete().catchError((_) => File(path));
    });
  }
}
