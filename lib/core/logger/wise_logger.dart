import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'log_entry.dart';
import 'log_level.dart';

/// Comprehensive file-based logger with automatic rotation
///
/// Features:
/// - Date-based file organization
/// - 10MB file size limit with automatic rotation
/// - Thread-safe logging using isolate
/// - Configurable log levels
class WiseLogger {
  static final WiseLogger _instance = WiseLogger._internal();
  factory WiseLogger() => _instance;
  WiseLogger._internal();

  // Maximum file size in bytes (10MB)
  static const int _maxFileSize = 10 * 1024 * 1024;

  // Base directory name for logs
  static const String _logsDirName = 'wise_spends_logs';

  // File name prefix
  static const String _fileNamePrefix = 'app_log';

  // Minimum log level (can be changed at runtime)
  LogLevel _minLogLevel = LogLevel.debug;

  // Whether logging is enabled
  bool _isEnabled = true;

  // Send port for isolate communication
  SendPort? _sendPort;
  ReceivePort? _receivePort;

  // Queue for messages before isolate is ready
  final List<_LogMessage> _pendingMessages = [];

  // Current log file info
  String? _currentLogDir;
  int _currentFileIndex = 1;
  DateTime? _currentLogDate;

  /// Initialize the logger
  Future<void> init() async {
    if (_receivePort != null) return; // Already initialized

    _receivePort = ReceivePort();

    // Capture token from the main isolate BEFORE spawning
    final rootIsolateToken = RootIsolateToken.instance!;

    // Spawn isolate for file I/O
    await Isolate.spawn(
      _loggerIsolate,
      _IsolateArgs(
        sendPort: _receivePort!.sendPort,
        rootIsolateToken: rootIsolateToken,
      ),
    );

    // Wait for send port from isolate
    _sendPort = await _receivePort!.first as SendPort;

    // Process any pending messages
    for (final message in _pendingMessages) {
      _sendPort!.send(message);
    }
    _pendingMessages.clear();
  }

  /// Set minimum log level
  void setMinLogLevel(LogLevel level) {
    _minLogLevel = level;
  }

  /// Enable or disable logging
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Check if logging is enabled for a specific level
  bool _shouldLog(LogLevel level) {
    return _isEnabled && level.shouldLog(_minLogLevel);
  }

  /// Log a trace message
  void trace(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.trace,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a debug message
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.debug,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an info message
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.info,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a warning message
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.warning,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log a fatal message
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.fatal,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Internal log method
  void _log(
    LogLevel level,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_shouldLog(level)) return;

    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      message: message,
      tag: tag,
      error: error?.toString(),
      stackTrace: stackTrace?.toString(),
    );

    final logMessage = _LogMessage(
      entry: entry,
      logDir: _currentLogDir,
      currentFileIndex: _currentFileIndex,
      currentLogDate: _currentLogDate,
    );

    if (_sendPort != null) {
      _sendPort!.send(logMessage);
    } else {
      _pendingMessages.add(logMessage);
    }
  }

  /// Update file info from isolate response
  void updateFileInfo(String logDir, int fileIndex, DateTime logDate) {
    _currentLogDir = logDir;
    _currentFileIndex = fileIndex;
    _currentLogDate = logDate;
  }

  /// Get the logs directory path
  static Future<String> getLogsDirPath() async {
    final appDir = await getApplicationDocumentsDirectory();
    final logsDir = Directory('${appDir.path}/$_logsDirName');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }
    return logsDir.path;
  }

  /// Get all log files grouped by date
  static Future<Map<String, List<File>>> getLogFilesByDate() async {
    final logsDir = await getLogsDirPath();
    final directory = Directory(logsDir);

    if (!await directory.exists()) {
      return {};
    }

    final files = await directory.list().toList();
    final Map<String, List<File>> groupedFiles = {};

    for (final entity in files) {
      if (entity is File && entity.path.endsWith('.log')) {
        final fileName = entity.path.split('/').last;
        // Extract date from filename (format: app_log_YYYY-MM-DD.log or app_log_YYYY-MM-DD_2.log)
        final dateMatch = RegExp(
          r'app_log_(\d{4}-\d{2}-\d{2})(?:_\d+)?\.log',
        ).firstMatch(fileName);

        if (dateMatch != null) {
          final date = dateMatch.group(1)!;
          groupedFiles.putIfAbsent(date, () => []).add(entity);
        }
      }
    }

    // Sort files within each date group by index
    for (final date in groupedFiles.keys) {
      groupedFiles[date]!.sort((a, b) {
        final aName = a.path.split('/').last;
        final bName = b.path.split('/').last;
        final aIndex = RegExp(
          r'app_log_$date(?:_(\d+))?\.log',
        ).firstMatch(aName)?.group(1);
        final bIndex = RegExp(
          r'app_log_$date(?:_(\d+))?\.log',
        ).firstMatch(bName)?.group(1);

        final aNum = aIndex != null ? int.tryParse(aIndex) ?? 1 : 1;
        final bNum = bIndex != null ? int.tryParse(bIndex) ?? 1 : 1;

        return aNum.compareTo(bNum);
      });
    }

    return groupedFiles;
  }

  /// Get all log files as a flat list
  static Future<List<File>> getAllLogFiles() async {
    final grouped = await getLogFilesByDate();
    final allFiles = <File>[];

    // Sort by date (newest first)
    final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    for (final date in sortedDates) {
      allFiles.addAll(grouped[date]!);
    }

    return allFiles;
  }

  /// Delete a specific log file
  static Future<bool> deleteLogFile(File file) async {
    try {
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Delete all log files for a specific date
  static Future<int> deleteLogsByDate(String date) async {
    final grouped = await getLogFilesByDate();
    final files = grouped[date] ?? [];

    int deleted = 0;
    for (final file in files) {
      if (await deleteLogFile(file)) {
        deleted++;
      }
    }
    return deleted;
  }

  /// Delete all log files
  static Future<int> deleteAllLogs() async {
    final files = await getAllLogFiles();
    int deleted = 0;
    for (final file in files) {
      if (await deleteLogFile(file)) {
        deleted++;
      }
    }
    return deleted;
  }

  /// Get file size in bytes
  static Future<int> getFileSize(File file) async {
    if (!await file.exists()) return 0;
    return await file.length();
  }

  /// Format file size for display
  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Read log file content
  static Future<String?> readLogFile(File file, {int? maxLines}) async {
    if (!await file.exists()) return null;

    try {
      if (maxLines != null) {
        final lines = await file.readAsLines();
        return lines.take(maxLines).join('\n');
      }
      return await file.readAsString();
    } catch (e) {
      return null;
    }
  }

  /// Dispose the logger
  Future<void> dispose() async {
    _receivePort?.close();
  }
}

class _IsolateArgs {
  final SendPort sendPort;
  final RootIsolateToken rootIsolateToken;

  _IsolateArgs({required this.sendPort, required this.rootIsolateToken});
}

/// Message sent to isolate for logging
class _LogMessage {
  final LogEntry entry;
  final String? logDir;
  final int currentFileIndex;
  final DateTime? currentLogDate;

  _LogMessage({
    required this.entry,
    this.logDir,
    required this.currentFileIndex,
    this.currentLogDate,
  });
}

/// Response from isolate with file info
class _FileInfoResponse {
  final String logDir;
  final int fileIndex;
  final DateTime logDate;

  _FileInfoResponse({
    required this.logDir,
    required this.fileIndex,
    required this.logDate,
  });
}

/// Isolate function for handling file I/O
void _loggerIsolate(_IsolateArgs args) async {
  // Must be called before ANY platform channel usage
  BackgroundIsolateBinaryMessenger.ensureInitialized(args.rootIsolateToken);

  final receivePort = ReceivePort();
  args.sendPort.send(receivePort.sendPort);

  String? currentLogDir;
  int currentFileIndex = 1;
  DateTime? currentLogDate;
  int currentFileSize = 0;

  await for (final message in receivePort) {
    if (message is _LogMessage) {
      // Initialize directory if needed
      if (currentLogDir == null) {
        final logsDir = await WiseLogger.getLogsDirPath();
        currentLogDir = logsDir;
      }

      // Check if we need a new file (new date or file size exceeded)
      final entryDate = LogEntry.getFileNameTimestamp(message.entry.timestamp);
      final needsNewFile =
          currentLogDate == null ||
          entryDate != LogEntry.getFileNameTimestamp(currentLogDate) ||
          currentFileSize >= WiseLogger._maxFileSize;

      if (needsNewFile) {
        currentLogDate = message.entry.timestamp;

        if (entryDate != LogEntry.getFileNameTimestamp(currentLogDate)) {
          currentFileIndex = 1;
        } else if (currentFileSize >= WiseLogger._maxFileSize) {
          currentFileIndex++;
        }

        currentFileSize = 0;

        // Send file info back to main isolate
        args.sendPort.send(
          _FileInfoResponse(
            logDir: currentLogDir,
            fileIndex: currentFileIndex,
            logDate: currentLogDate,
          ),
        );
      }

      // Write log entry
      final logEntryDate = LogEntry.getFileNameTimestamp(
        message.entry.timestamp,
      );
      final baseName = '${WiseLogger._fileNamePrefix}_$logEntryDate';
      final fileName = currentFileIndex == 1
          ? '$baseName.log'
          : '${baseName}_$currentFileIndex.log';
      final currentLogFile = '$currentLogDir/$fileName';

      final file = File(currentLogFile);
      final logLine = '${message.entry.toLogString()}\n';

      // Append to file
      await file.writeAsString(logLine, mode: FileMode.append);
      currentFileSize += logLine.length;
    }
  }
}
