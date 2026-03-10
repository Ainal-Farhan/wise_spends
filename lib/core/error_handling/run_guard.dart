import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';

/// A widget that catches all uncaught Flutter and async errors and shows
/// a user-friendly error dialog.
class RunGuard extends StatefulWidget {
  final Widget child;
  final GlobalKey<NavigatorState>? navigatorKey;

  final void Function(Object error, StackTrace stackTrace)? onError;

  const RunGuard({
    super.key,
    required this.child,
    this.navigatorKey,
    this.onError,
  });

  @override
  State<RunGuard> createState() => _RunGuardState();
}

class _RunGuardState extends State<RunGuard> {
  @override
  void initState() {
    super.initState();
    _initializeErrorHandlers();
  }

  void _initializeErrorHandlers() {
    FlutterError.onError = (FlutterErrorDetails details) {
      _handleError(details.exception, details.stack ?? StackTrace.current);
    };

    ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _handleError(error, stack);
      return true;
    };
  }

  void _handleError(Object error, StackTrace stackTrace) {
    WiseLogger().fatal(
      'Uncaught error: $error',
      tag: 'RunGuard',
      error: error,
      stackTrace: stackTrace,
    );

    widget.onError?.call(error, stackTrace);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorDialog(error);
    });
  }

  void _showErrorDialog(Object error) {
    // Prefer the navigator key context — guaranteed to be inside MaterialApp
    // and valid even when this widget's own context is stale or unmounted.
    final navigatorContext = widget.navigatorKey?.currentContext;

    // Fall back to own context only when RunGuard is placed inside
    // MaterialApp (e.g. via builder) and the context is still alive.
    final ctx = navigatorContext ?? (mounted ? context : null);

    if (ctx == null || !ctx.mounted) return;

    showErrorDialog(
      context: ctx,
      title: 'Something Went Wrong',
      message: _extractUserFriendlyMessage(error),
    );
  }

  String _extractUserFriendlyMessage(Object error) {
    final errorString = error.toString();

    if (error is TypeError) {
      return 'An unexpected error occurred. Please try again.';
    } else if (error is FormatException) {
      return 'Invalid data format. Please check your input.';
    } else if (error is RangeError) {
      return 'Invalid value provided. Please try again.';
    } else if (error is StateError) {
      return 'Application state error. Please restart the app.';
    } else if (errorString.contains('SocketException') ||
        errorString.contains('Network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorString.contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('Permission')) {
      return 'Permission denied. Please check app permissions.';
    }

    return 'An unexpected error occurred. Our team has been notified.';
  }

  @override
  Widget build(BuildContext context) => widget.child;

  @override
  void dispose() {
    FlutterError.onError = null;
    ui.PlatformDispatcher.instance.onError = null;
    super.dispose();
  }
}

/// Convenience extension — see [RunGuard] for correct placement rules.
extension RunGuardExtension on Widget {
  Widget withRunGuard({
    GlobalKey<NavigatorState>? navigatorKey,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return RunGuard(navigatorKey: navigatorKey, onError: onError, child: this);
  }
}
