import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise_spends/core/services/backup/backup_restore_bloc.dart';
import 'package:wise_spends/core/services/backup/workmanager/backup_task_config.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:workmanager/workmanager.dart';

/// SharedPreferences key for the auto-backup toggle.
const _kAutoBackupKey = 'backup_auto_enabled';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final AppDatabase _database = AppDatabase();

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
  /// Returns `true` on success, `false` when the user cancels.
  Future<bool> restore() async {
    try {
      return await _database.restore('.json');
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }

  /// Restores directly from [filePath] without showing a file picker.
  /// File type is inferred from the extension (.json / .sqlite).
  Future<bool> restoreFromPath(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('Backup file not found: $filePath');
    }
    try {
      final type = filePath.endsWith('.sqlite') ? '.sqlite' : '.json';
      return await _database.restoreFromPath(filePath, type);
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

  // ─── Helpers ─────────────────────────────────────────────────────────────

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
