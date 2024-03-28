import 'package:wise_spends/theme/theme_list/i_theme.dart';

class DefaultTheme implements ITheme {
  DefaultTheme._internal();
  static final DefaultTheme _defaultTheme = DefaultTheme._internal();
  factory DefaultTheme() {
    return _defaultTheme;
  }
}
