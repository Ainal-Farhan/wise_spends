import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:wise_spends/data/db/app_database.dart';

class BackupService {
  static final BackupService _instance = BackupService._internal();
  factory BackupService() => _instance;
  BackupService._internal();

  final AppDatabase _database = AppDatabase();

  /// Export data and share it using share_plus
  Future<void> backupAndShare({String type = '.json'}) async {
    String? filePath;
    try {
      // Export data to a temporary file
      filePath = await _database.exportInto(type);
      
      // Share the file using share_plus
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Wise Spends Backup File',
      );
    } catch (e) {
      throw Exception('Backup failed: $e');
    } finally {
      // Clean up the temporary file after sharing attempt
      if (filePath != null) {
        try {
          File file = File(filePath);
          if (await file.exists()) {
            await file.delete();
          }
        } catch (e) {
          // If cleanup fails, just silently continue as backup was already successful
          // File cleanup is best-effort only
        }
      }
    }
  }

  /// Export data directly to Downloads folder
  Future<String> backupToInternalStorageMedia({String type = '.json'}) async {
    try {
      String filePath = await _database.exportToInternalStorageMedia(type);
      return filePath;
    } catch (e) {
      throw Exception('Backup to downloads failed: $e');
    }
  }

  /// Restore data from file
  Future<bool> restore() async {
    try {
      bool result = await _database.restore('.json');
      return result;
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }
}