abstract class ConfigConstant {
  static const themeDefault = 'default';
  static const themeDark = 'dark';
  static final List<String> themeList = List.unmodifiable([
    themeDefault,
    themeDark,
  ]);
  static const defaultTheme = themeDefault;

  static const languageEnglish = 'en';
  static final List<String> languageList = List.unmodifiable([
    languageEnglish,
  ]);
  static const defaultLanguage = languageEnglish;

  static const emptyString = '';

  // file name
  static const String configFileName = 'app_config.json';

  // file name with /
  static const String configFileNameForPath = '/app_config.json';

  // json label
  static const String jsonLabelTheme = 'theme';
  static const String jsonLabelLanguage = 'language';
}
