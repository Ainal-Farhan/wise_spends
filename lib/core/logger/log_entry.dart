import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'log_level.dart';

/// Represents a single log entry
class LogEntry extends Equatable {
  final DateTime timestamp;
  final LogLevel level;
  final String message;
  final String? tag;
  final String? error;
  final String? stackTrace;

  const LogEntry({
    required this.timestamp,
    required this.level,
    required this.message,
    this.tag,
    this.error,
    this.stackTrace,
  });

  /// Format timestamp for display
  String get formattedTimestamp {
    return DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(timestamp);
  }

  /// Format timestamp for file name
  static String getFileNameTimestamp(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'level': level.name,
      'message': message,
      'tag': tag,
      'error': error,
      'stackTrace': stackTrace,
    };
  }

  /// Create from JSON
  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      timestamp: DateTime.parse(json['timestamp']),
      level: LogLevel.values.firstWhere(
        (e) => e.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      message: json['message'],
      tag: json['tag'],
      error: json['error'],
      stackTrace: json['stackTrace'],
    );
  }

  /// Convert to string for file storage (plain text format)
  String toLogString() {
    final buffer = StringBuffer();
    buffer.write('[$formattedTimestamp]');
    buffer.write(' [${level.name}]');
    if (tag != null && tag!.isNotEmpty) {
      buffer.write(' [$tag]');
    }
    buffer.write(' $message');
    if (error != null && error!.isNotEmpty) {
      buffer.write('\n  Error: $error');
    }
    if (stackTrace != null && stackTrace!.isNotEmpty) {
      buffer.write('\n  StackTrace:\n$stackTrace');
    }
    return buffer.toString();
  }

  @override
  List<Object?> get props => [
        timestamp,
        level,
        message,
        tag,
        error,
        stackTrace,
      ];
}
