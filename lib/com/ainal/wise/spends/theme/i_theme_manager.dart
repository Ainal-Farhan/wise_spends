import 'package:wise_spends/com/ainal/wise/spends/theme/colors/i_color_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/i_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_manager.dart';

abstract class IThemeManager {
  factory IThemeManager() {
    return ThemeManager();
  }

  Future<void> init();
  ITheme getCurrentTheme();
  bool validateListOfWidgets();
  IColorTheme get colorTheme;
}
