/// Log levels for the application logger
/// Ordered from least to most severe
enum LogLevel {
  trace,    // Detailed tracing information for debugging
  debug,    // Debugging information
  info,     // General informational messages
  warning,  // Warning messages (potential issues)
  error,    // Error messages (actual errors)
  fatal,    // Critical errors (application-crashing)
}

extension LogLevelExtension on LogLevel {
  /// Get the display name for the log level
  String get name {
    switch (this) {
      case LogLevel.trace:
        return 'TRACE';
      case LogLevel.debug:
        return 'DEBUG';
      case LogLevel.info:
        return 'INFO';
      case LogLevel.warning:
        return 'WARN';
      case LogLevel.error:
        return 'ERROR';
      case LogLevel.fatal:
        return 'FATAL';
    }
  }

  /// Get the color code for the log level (for UI display)
  int get colorValue {
    switch (this) {
      case LogLevel.trace:
        return 0xFF9E9E9E; // Grey
      case LogLevel.debug:
        return 0xFF2196F3; // Blue
      case LogLevel.info:
        return 0xFF4CAF50; // Green
      case LogLevel.warning:
        return 0xFFFF9800; // Orange
      case LogLevel.error:
        return 0xFFF44336; // Red
      case LogLevel.fatal:
        return 0xFF9C27B0; // Purple
    }
  }

  /// Check if this level should be logged based on minimum level
  bool shouldLog(LogLevel minimumLevel) {
    return index >= minimumLevel.index;
  }
}
