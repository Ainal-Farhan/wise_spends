import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

class WidgetService {
  static const String _appGroupId = 'group.com.aftechlabs.wisespends';
  static const String _androidWidgetName = 'QuickTransactionWidgetProvider';
  static const String _iOSWidgetName = 'QuickTransactionWidget';

  // ─────────────────────────────────────────────
  // Init — call once in main.dart
  // ─────────────────────────────────────────────

  static Future<void> initialize() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Register URI callback (home_widget deep-link — optional, kept for iOS)
  static void registerInteractivityCallback() {
    // No-op for Android Intent-based flow.
    // Add HomeWidget.widgetClicked.listen(...) here if you switch to URI scheme.
  }

  // ─────────────────────────────────────────────
  // Data — called from TransactionRepository
  // ─────────────────────────────────────────────

  /// Save last transaction and refresh all widgets.
  static Future<void> updateLastTransaction(
    TransactionEntity transaction,
  ) async {
    await HomeWidget.saveWidgetData<String>(
      'last_transaction_title',
      transaction.title,
    );
    await HomeWidget.saveWidgetData<String>(
      'last_transaction_amount',
      transaction.amount.toStringAsFixed(2),
    );
    await HomeWidget.saveWidgetData<String>(
      'last_transaction_type',
      transaction.type.name, // 'income' | 'expense' | 'transfer'
    );
    await _refreshWidget();
  }

  /// Save hide/show preference and refresh widget.
  static Future<void> setHideDetails({required bool hide}) async {
    await HomeWidget.saveWidgetData<bool>('hide_details', hide);
    await _refreshWidget();
  }

  // ─────────────────────────────────────────────
  // Widget pin / count — called from widget screens
  // ─────────────────────────────────────────────

  /// Returns number of active widget instances (Android only; iOS returns 0).
  static Future<int> getInstalledWidgetsCount() async {
    try {
      final ids = await HomeWidget.getInstalledWidgets();
      return ids.length;
    } catch (_) {
      return 0;
    }
  }

  /// Whether the device supports the "pin widget" flow (Android 8+).
  static Future<bool> isPinWidgetSupported() async {
    try {
      return await HomeWidget.isRequestPinWidgetSupported() ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Trigger the system "add widget" pin sheet (Android 8+).
  static Future<void> requestPinWidget() async {
    try {
      await HomeWidget.requestPinWidget(androidName: _androidWidgetName);
    } catch (e) {
      debugPrint('requestPinWidget failed: $e');
    }
  }

  // ─────────────────────────────────────────────
  // Dialog — called from widget settings / info screens
  // ─────────────────────────────────────────────

  static void showWidgetInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.add_home_work, size: 24),
            SizedBox(width: 8),
            Text('Add Widget'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('To add the WiseSpends widget to your home screen:'),
            SizedBox(height: 12),
            _Step(
              number: '1',
              text: 'Long-press an empty area on your home screen',
            ),
            _Step(number: '2', text: 'Tap "Widgets"'),
            _Step(
              number: '3',
              text: 'Find "WiseSpends" and drag it to your home screen',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
          FutureBuilder<bool>(
            future: isPinWidgetSupported(),
            builder: (context, snap) {
              if (snap.data != true) return const SizedBox.shrink();
              return FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  requestPinWidget();
                },
                child: const Text('Add Automatically'),
              );
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Private
  // ─────────────────────────────────────────────

  static Future<void> _refreshWidget() async {
    await HomeWidget.updateWidget(
      androidName: _androidWidgetName,
      iOSName: _iOSWidgetName,
    );
  }
}

/// Small helper widget used inside the dialog only.
class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});
  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            child: Text(number, style: const TextStyle(fontSize: 11)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
