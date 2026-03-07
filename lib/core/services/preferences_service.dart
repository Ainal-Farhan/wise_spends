import 'package:shared_preferences/shared_preferences.dart';
import 'package:wise_spends/core/config/app_locale.dart';

/// User Preferences Service
/// Handles persistent storage of user settings using SharedPreferences
class PreferencesService {
  static final PreferencesService _instance = PreferencesService._internal();
  factory PreferencesService() => _instance;
  PreferencesService._internal();

  SharedPreferences? _prefs;

  // Preference keys
  static const String _languageKey = 'language_code';
  static const String _themeKey = 'theme_mode';

  /// Initialize preferences
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Get current language code
  String getLanguageCode() {
    return _prefs?.getString(_languageKey) ?? 'en';
  }

  /// Save language preference
  Future<void> saveLanguage(String languageCode) async {
    await _prefs?.setString(_languageKey, languageCode);
  }

  /// Get current theme mode (0=system, 1=light, 2=dark)
  int getThemeMode() {
    return _prefs?.getInt(_themeKey) ?? 0; // Default to system
  }

  /// Save theme preference
  Future<void> saveTheme(int themeIndex) async {
    await _prefs?.setInt(_themeKey, themeIndex);
  }

  /// Get AppLocale from saved language code
  AppLocale getAppLocale() {
    final code = getLanguageCode();
    return AppLocale.fromCode(code);
  }

  /// Clear all preferences
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
