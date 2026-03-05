/// Application locale enum supporting English and Malay
enum AppLocale {
  english('en', 'English'),
  malay('ms', 'Bahasa Melayu');

  final String code;
  final String nativeName;

  const AppLocale(this.code, this.nativeName);

  /// Get locale from code
  static AppLocale fromCode(String code) {
    if (code.startsWith('ms')) return AppLocale.malay;
    return AppLocale.english;
  }

  /// Get all supported locales
  static List<AppLocale> get supportedLocales => [
        AppLocale.english,
        AppLocale.malay,
      ];
}
