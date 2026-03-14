import 'package:wise_spends/core/services/preferences_service.dart';
import 'log_level.dart';

/// Thin facade kept for backward compatibility.
/// All reads/writes delegate to [PreferencesService] — the single source of
/// truth for SharedPreferences. No raw [SharedPreferences] access here.
class LoggerPreferencesService {
  static final LoggerPreferencesService _instance =
      LoggerPreferencesService._internal();
  factory LoggerPreferencesService() => _instance;
  LoggerPreferencesService._internal();

  final _prefs = PreferencesService();

  /// Must be called once before any getter is used.
  Future<void> init() => _prefs.init();

  bool isLoggingEnabled() => _prefs.isLoggingEnabled();

  Future<void> setLoggingEnabled(bool enabled) =>
      _prefs.setLoggingEnabled(enabled);

  LogLevel getMinLogLevel() => _prefs.getMinLogLevel();

  Future<void> setMinLogLevel(LogLevel level) => _prefs.setMinLogLevel(level);

  List<LogLevel> getAvailableLevels() => LogLevel.values;

  Future<void> clear() => _prefs.clearLoggerPrefs();
}
