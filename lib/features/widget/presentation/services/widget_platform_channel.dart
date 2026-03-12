import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/router/route_arguments.dart';

class WidgetPlatformChannel {
  static const MethodChannel _channel = MethodChannel(
    'com.wisespends.app/widget',
  );

  static void initialize() {
    _channel.setMethodCallHandler(_handleMethodCall);
    _checkWidgetLaunch();
  }

  static Future<void> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'quickTransactionRequested':
        // Hot path: app already running, onNewIntent fired
        final type = call.arguments as String?;
        _navigateToAddTransaction(type);
        break;
      default:
        debugPrint('WidgetPlatformChannel: unknown method ${call.method}');
    }
  }

  static Future<void> _checkWidgetLaunch() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final type = await _channel.invokeMethod<String>(
        'getQuickTransactionType',
      );
      if (type != null && type.isNotEmpty) {
        debugPrint('Cold widget launch: $type');
        _navigateToAddTransaction(type);
      }
    } catch (e) {
      debugPrint('Widget launch check failed: $e');
    }
  }

  static void _navigateToAddTransaction(String? type) {
    final transactionType = switch (type) {
      'expense' => TransactionType.expense,
      'income' => TransactionType.income,
      'transfer' => TransactionType.transfer,
      _ => TransactionType.expense,
    };

    // Use navigatorKey — always valid, no context needed
    AppRouter.navigatorKey.currentState?.pushNamed(
      AppRoutes.addTransaction,
      arguments: AddTransactionArgs(preselectedType: transactionType),
    );
  }
}
