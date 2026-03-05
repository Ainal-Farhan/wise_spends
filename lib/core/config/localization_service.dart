import 'package:wise_spends/core/config/app_locale.dart';
import 'package:wise_spends/shared/resources/l10n/strings_en.dart';
import 'package:wise_spends/shared/resources/l10n/strings_ms.dart';

/// Localization service providing translated strings
class LocalizationService {
  static final LocalizationService _instance = LocalizationService._internal();
  factory LocalizationService() => _instance;
  LocalizationService._internal();

  AppLocale _currentLocale = AppLocale.english;
  Map<String, String> _strings = EnglishStrings.strings;

  /// Get current locale
  AppLocale get currentLocale => _currentLocale;

  /// Get current strings
  Map<String, String> get strings => _strings;

  /// Set locale
  void setLocale(AppLocale locale) {
    _currentLocale = locale;
    _strings = locale == AppLocale.malay
        ? MalayStrings.strings
        : EnglishStrings.strings;
  }

  /// Get string by key
  String get(String key, [Map<String, String>? params]) {
    String value = _strings[key] ?? EnglishStrings.strings[key] ?? key;
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value;
  }

  /// Get locale display name
  String getLocaleDisplayName(AppLocale locale) => locale.nativeName;

  /// Check if current locale is Malay
  bool get isMalay => _currentLocale == AppLocale.malay;

  /// Check if current locale is English
  bool get isEnglish => _currentLocale == AppLocale.english;
}

/// Extension for easy access to localized strings
extension LocalizationExtension on String {
  String get tr => LocalizationService().get(this);
  
  String trWith(Map<String, String> params) => 
      LocalizationService().get(this, params);
}
