import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/impl/repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:workmanager/workmanager.dart';

/// Background callback dispatcher for Workmanager
/// This function is called when doing background work initiated from the widget
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('Background task executed: $taskName');

    try {
      // Initialize repositories for background work
      final repositoryLocator = RepositoryLocator();
      SingletonUtil.registerSingleton<IRepositoryLocator>(repositoryLocator);

      final transactionRepository = repositoryLocator
          .getTransactionRepository();

      // Get recent transactions
      final transactions = await transactionRepository.fetchRecent(limit: 5);

      final now = DateTime.now();

      // Update widget data - only last transaction info, no balance
      await Future.wait<bool?>([
        HomeWidget.saveWidgetData(
          'last_transaction_title',
          transactions.isNotEmpty
              ? transactions.first.title
              : 'No transactions',
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
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ),
      ]);

      // Update Android widget
      await HomeWidget.updateWidget(
        name: 'QuickTransactionWidget',
        androidName: 'quick_transaction_widget',
      );

      // Update Android Glance widget if available
      if (Platform.isAndroid) {
        await HomeWidget.updateWidget(
          qualifiedAndroidName:
              'com.my.aftechlabs.wise.spends.QuickTransactionWidgetProvider',
        );
      }

      debugPrint('Widget updated successfully in background');
      return true;
    } catch (e) {
      debugPrint('Error updating widget in background: $e');
      return false;
    }
  });
}

/// Called when doing background work initiated from widget interaction
/// This handles interactive callbacks from the widget (e.g., tapping buttons)
@pragma("vm:entry-point")
Future<void> interactiveCallback(Uri? data) async {
  debugPrint('Interactive callback triggered: $data');

  if (data == null) return;

  try {
    // Set app group ID for iOS
    await HomeWidget.setAppGroupId('group.wise_spends.widgets');

    final action = data.host;
    final transactionType = data.queryParameters['type'];

    debugPrint('Widget action: $action, type: $transactionType');

    // Save the transaction type for the app to process
    if (transactionType != null) {
      await HomeWidget.saveWidgetData('launch_type', transactionType);
    }

    // Update last interaction time
    final now = DateTime.now();
    await HomeWidget.saveWidgetData(
      'last_interaction',
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
    );

    // Update widget to show interaction
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
    debugPrint('Error in interactive callback: $e');
  }
}

/// Widget background update service
class WidgetBackgroundService {
  static const String _backgroundTaskName = 'widgetBackgroundUpdate';
  static const String _taskIdentifier = 'widget_update_task';

  /// Initialize background updates
  static void initialize() {
    Workmanager().initialize(callbackDispatcher);
  }

  /// Start periodic background updates (every 15 minutes minimum on Android)
  static void startPeriodicUpdates() {
    Workmanager().registerPeriodicTask(
      _taskIdentifier,
      _backgroundTaskName,
      frequency: const Duration(minutes: 15), // Minimum on Android
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
    debugPrint('Widget periodic updates started');
  }

  /// Stop periodic background updates
  static void stopPeriodicUpdates() {
    Workmanager().cancelByUniqueName(_taskIdentifier);
    debugPrint('Widget periodic updates stopped');
  }

  /// Trigger an immediate background update
  static Future<void> triggerImmediateUpdate() async {
    try {
      // Initialize repositories for immediate update
      final repositoryLocator = RepositoryLocator();
      SingletonUtil.registerSingleton<IRepositoryLocator>(repositoryLocator);

      final transactionRepository = repositoryLocator
          .getTransactionRepository();

      // Get recent transactions
      final transactions = await transactionRepository.fetchRecent(limit: 5);

      final now = DateTime.now();

      // Update widget data - only last transaction info, no balance
      await Future.wait<bool?>([
        HomeWidget.saveWidgetData(
          'last_transaction_title',
          transactions.isNotEmpty
              ? transactions.first.title
              : 'No transactions',
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
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        ),
      ]);

      // Update widgets
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

      debugPrint('Immediate widget update completed');
    } catch (e) {
      debugPrint('Error in immediate update: $e');
    }
  }
}
