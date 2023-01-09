import 'package:wise_spends/com/ainal/wise/spends/theme/colors/i_color_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/i_theme.dart';

abstract class IThemeManager {
  Future<void> init();
  ITheme getCurrentTheme();
  bool validateListOfWidgets();
  IColorTheme get colorTheme;
}
