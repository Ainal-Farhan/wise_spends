/// Constants for the Workmanager background backup task.
///
/// Centralised here so [BackupService], [main.dart], and any future
/// notification handler all reference the same strings.
abstract class BackupTaskConfig {
  BackupTaskConfig._();

  /// Unique name used to register / cancel the periodic task.
  static const String uniqueName = 'wise_spends_auto_backup';

  /// Task name passed to the [callbackDispatcher] switch statement.
  static const String taskName = 'autoBackupTask';

  /// How often the backup runs. Workmanager minimum is 15 minutes;
  /// weekly is a sensible default for a finance app.
  static const Duration frequency = Duration(days: 7);

  /// Keep at most this many auto-backups before the oldest is pruned.
  /// Set to `null` to disable pruning.
  static const int maxAutoBackups = 5;
}
