import 'package:shared_preferences/shared_preferences.dart';
import 'log_level.dart';

/// Logger Preferences Service
/// Handles persistent storage of logger settings using SharedPreferences
class LoggerPreferencesService {
  static final LoggerPreferencesService _instance =
      LoggerPreferencesService._internal();
  factory LoggerPreferencesService() => _instance;
  LoggerPreferencesService._internal();

  SharedPreferences? _prefs;

  // Preference keys
  static const String _loggingEnabledKey = 'logging_enabled';
  static const String _logLevelKey = 'log_level';

  /// Initialize preferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if logging is enabled
  bool isLoggingEnabled() {
    return _prefs?.getBool(_loggingEnabledKey) ?? true;
  }

  /// Enable or disable logging
  Future<void> setLoggingEnabled(bool enabled) async {
    await _prefs?.setBool(_loggingEnabledKey, enabled);
  }

  /// Get current minimum log level
  LogLevel getMinLogLevel() {
    final levelIndex = _prefs?.getInt(_logLevelKey) ?? LogLevel.debug.index;
    if (levelIndex < 0 || levelIndex >= LogLevel.values.length) {
      return LogLevel.debug;
    }
    return LogLevel.values[levelIndex];
  }

  /// Save minimum log level
  Future<void> setMinLogLevel(LogLevel level) async {
    await _prefs?.setInt(_logLevelKey, level.index);
  }

  /// Get all available log levels for UI selection
  List<LogLevel> getAvailableLevels() {
    return LogLevel.values;
  }

  /// Clear logger preferences
  Future<void> clear() async {
    await _prefs?.remove(_loggingEnabledKey);
    await _prefs?.remove(_logLevelKey);
  }
}
