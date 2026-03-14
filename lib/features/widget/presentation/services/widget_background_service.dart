import 'dart:async';
import 'dart:io';

import 'package:home_widget/home_widget.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/impl/repository_locator.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/features/settings/data/services/backup_service.dart';
import 'package:wise_spends/features/settings/data/workmanager/backup_task_config.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:workmanager/workmanager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Single top-level callbackDispatcher
//
// Workmanager only supports ONE callbackDispatcher per app.
// All background tasks — widget updates, auto-backup, etc. — must be
// routed through this single switch statement.
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    WiseLogger().debug('Background task executed: $taskName');

    switch (taskName) {
      case WidgetBackgroundService.backgroundTaskName:
        return await _runWidgetUpdate();

      case BackupTaskConfig.taskName:
        return await _runAutoBackup();

      default:
        WiseLogger().debug('Unknown background task: $taskName');
        // Return true so Workmanager does not retry an unrecognised task.
        return true;
    }
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget update task
// ─────────────────────────────────────────────────────────────────────────────

Future<bool> _runWidgetUpdate() async {
  try {
    final repositoryLocator = RepositoryLocator();
    SingletonUtil.registerSingleton<IRepositoryLocator>(repositoryLocator);

    final transactionRepository = repositoryLocator.getTransactionRepository();

    final transactions = await transactionRepository.fetchRecent(limit: 5);
    final now = DateTime.now();

    await Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'last_transaction_title',
        transactions.isNotEmpty ? transactions.first.title : 'No transactions',
      ),
      HomeWidget.saveWidgetData(
        'last_transaction_amount',
        transactions.isNotEmpty
            ? transactions.first.amount.toStringAsFixed(2)
            : '0.00',
      ),
      HomeWidget.saveWidgetData(
        'last_transaction_type',
        transactions.isNotEmpty ? transactions.first.type.name : 'none',
      ),
      HomeWidget.saveWidgetData(
        'last_update',
        '${now.hour.toString().padLeft(2, '0')}:'
            '${now.minute.toString().padLeft(2, '0')}',
      ),
    ]);

    await HomeWidget.updateWidget(
      name: 'QuickTransactionWidget',
      androidName: 'quick_transaction_widget',
    );

    if (Platform.isAndroid) {
      await HomeWidget.updateWidget(
        qualifiedAndroidName:
            'com.my.aftechlabs.wise.spends.QuickTransactionWidgetProvider',
      );
    }

    WiseLogger().debug('Widget updated successfully in background');
    return true;
  } catch (e) {
    WiseLogger().debug('Error updating widget in background: $e');
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Auto-backup task
// ─────────────────────────────────────────────────────────────────────────────

Future<bool> _runAutoBackup() async {
  try {
    final service = BackupService();

    await service.backupToInternalStorage(type: '.json');

    // Prune oldest backups if a cap is configured.
    final max = BackupTaskConfig.maxAutoBackups;
    final backups = await service.listBackups();
    if (backups.length > max) {
      // listBackups() returns newest-first, so trim from the tail.
      final toDelete = backups.sublist(max);
      for (final old in toDelete) {
        await service.deleteBackupFile(old.filePath);
      }
    }

    WiseLogger().debug('Auto-backup completed successfully');
    return true;
  } catch (e) {
    WiseLogger().debug('Error during auto-backup: $e');
    return false;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Interactive widget callback (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

@pragma('vm:entry-point')
Future<void> interactiveCallback(Uri? data) async {
  WiseLogger().debug('Interactive callback triggered: $data');

  if (data == null) return;

  try {
    await HomeWidget.setAppGroupId('group.wise_spends.widgets');

    final action = data.host;
    final transactionType = data.queryParameters['type'];

    WiseLogger().debug('Widget action: $action, type: $transactionType');

    if (transactionType != null) {
      await HomeWidget.saveWidgetData('launch_type', transactionType);
    }

    final now = DateTime.now();
    await HomeWidget.saveWidgetData(
      'last_interaction',
      '${now.hour.toString().padLeft(2, '0')}:'
          '${now.minute.toString().padLeft(2, '0')}',
    );

    await Future.wait([
      HomeWidget.updateWidget(
        name: 'QuickTransactionWidget',
        iOSName: 'QuickTransactionWidget',
      ),
      if (Platform.isAndroid)
        HomeWidget.updateWidget(
          qualifiedAndroidName:
              'com.my.aftechlabs.wise.spends.QuickTransactionWidgetProvider',
        ),
    ]);
  } catch (e) {
    WiseLogger().debug('Error in interactive callback: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// WidgetBackgroundService (unchanged public API)
// ─────────────────────────────────────────────────────────────────────────────

class WidgetBackgroundService {
  // Exposed so the callbackDispatcher switch can reference it without
  // duplicating the string literal.
  static const String backgroundTaskName = 'widgetBackgroundUpdate';
  static const String _taskIdentifier = 'widget_update_task';

  /// Initialise Workmanager with the single shared [callbackDispatcher].
  ///
  /// Call this once in main.dart — do NOT call Workmanager().initialize()
  /// anywhere else in the app.
  static void initialize() {
    Workmanager().initialize(callbackDispatcher);
  }

  /// Register the widget periodic update task (every 15 minutes minimum).
  static void startPeriodicUpdates() {
    Workmanager().registerPeriodicTask(
      _taskIdentifier,
      backgroundTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    WiseLogger().debug('Widget periodic updates started');
  }

  /// Cancel the widget periodic update task.
  static void stopPeriodicUpdates() {
    Workmanager().cancelByUniqueName(_taskIdentifier);
    WiseLogger().debug('Widget periodic updates stopped');
  }

  /// Run a widget update immediately in the foreground (e.g. after a new
  /// transaction is saved).
  static Future<void> triggerImmediateUpdate() async {
    // Delegates to the shared helper so the logic is never duplicated.
    await _runWidgetUpdate();
  }
}
