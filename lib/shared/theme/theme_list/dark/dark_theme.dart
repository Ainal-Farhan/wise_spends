import 'package:wise_spends/shared/theme/theme_list/i_theme.dart';

class DarkTheme implements ITheme {
  DarkTheme._internal();
  static final DarkTheme _darkTheme = DarkTheme._internal();
  factory DarkTheme() {
    return _darkTheme;
  }
}