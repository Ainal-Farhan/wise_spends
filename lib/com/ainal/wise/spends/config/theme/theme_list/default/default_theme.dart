import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/i_theme.dart';

class DefaultTheme implements ITheme {
  DefaultTheme._internal();
  static final DefaultTheme _defaultTheme = DefaultTheme._internal();
  factory DefaultTheme() {
    return _defaultTheme;
  }
}
