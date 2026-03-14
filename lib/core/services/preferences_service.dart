import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise_spends/core/config/app_locale.dart';
import 'package:wise_spends/core/logger/log_level.dart';

/// Single source of truth for all [SharedPreferences] access in the app.
///
/// There is one shared [SharedPreferences] instance, loaded once via [init].
///
/// ## Usage
/// ```dart
/// final prefs = PreferencesService();
/// await prefs.init();           // call once at app startup
/// prefs.getLanguageCode();      // synchronous read thereafter
/// await prefs.saveTheme(1);     // async write
/// ```
class PreferencesService {
  // ── Singleton ──────────────────────────────────────────────────────────────
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  // ── Keys ───────────────────────────────────────────────────────────────────
  // All keys live here so there is zero chance of collision between features.

  // Settings
  static const String _languageKey = 'language_code';
  static const String _themeKey = 'theme_mode';

  // Logger
  static const String _loggingEnabledKey = 'logging_enabled';
  static const String _logLevelKey = 'log_level';

  // Widget
  static const String _widgetQuickAccessKey = 'quick_access_button_enabled';
  static const String _widgetHideDetailsKey = 'widget_hide_details';

  // Backup
  static const String _autoBackupKey = 'backup_auto_enabled';

  // ── Init ───────────────────────────────────────────────────────────────────

  /// Must be called once before any synchronous getter is used.
  /// Safe to call multiple times — subsequent calls are no-ops.
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Settings: Language ─────────────────────────────────────────────────────

  String getLanguageCode() => _prefs?.getString(_languageKey) ?? 'en';

  Future<void> saveLanguage(String languageCode) async =>
      _prefs?.setString(_languageKey, languageCode);

  AppLocale getAppLocale() => AppLocale.fromCode(getLanguageCode());

  // ── Settings: Theme ────────────────────────────────────────────────────────

  /// 0 = system (default), 1 = light, 2 = dark
  int getThemeMode() => _prefs?.getInt(_themeKey) ?? 0;

  Future<void> saveTheme(int themeIndex) async =>
      _prefs?.setInt(_themeKey, themeIndex);

  // ── Logger ─────────────────────────────────────────────────────────────────

  bool isLoggingEnabled() => _prefs?.getBool(_loggingEnabledKey) ?? true;

  Future<void> setLoggingEnabled(bool enabled) async =>
      _prefs?.setBool(_loggingEnabledKey, enabled);

  LogLevel getMinLogLevel() {
    final index = _prefs?.getInt(_logLevelKey) ?? LogLevel.debug.index;
    if (index < 0 || index >= LogLevel.values.length) return LogLevel.debug;
    return LogLevel.values[index];
  }

  Future<void> setMinLogLevel(LogLevel level) async =>
      _prefs?.setInt(_logLevelKey, level.index);

  // ── Widget ─────────────────────────────────────────────────────────────────

  bool getWidgetQuickAccessEnabled() =>
      _prefs?.getBool(_widgetQuickAccessKey) ?? true;

  Future<void> setWidgetQuickAccessEnabled(bool enabled) async =>
      _prefs?.setBool(_widgetQuickAccessKey, enabled);

  bool getWidgetHideDetails() =>
      _prefs?.getBool(_widgetHideDetailsKey) ?? false;

  Future<void> setWidgetHideDetails(bool hide) async =>
      _prefs?.setBool(_widgetHideDetailsKey, hide);

  // ── Backup ─────────────────────────────────────────────────────────────────

  bool getAutoBackupEnabled() => _prefs?.getBool(_autoBackupKey) ?? false;

  Future<void> setAutoBackupEnabled(bool enabled) async =>
      _prefs?.setBool(_autoBackupKey, enabled);

  // ── Nuclear option ─────────────────────────────────────────────────────────

  /// Clears ALL preferences. Use only on sign-out / data reset.
  Future<void> clearAll() async => _prefs?.clear();

  /// Clears only the logger-related keys (used in debug tooling).
  Future<void> clearLoggerPrefs() async {
    await _prefs?.remove(_loggingEnabledKey);
    await _prefs?.remove(_logLevelKey);
  }
}
