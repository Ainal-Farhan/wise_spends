import 'package:wise_spends/manager/i_manager.dart';
import 'package:wise_spends/theme/colors/i_color_theme.dart';
import 'package:wise_spends/theme/theme_list/i_theme.dart';

abstract class IThemeManager extends IManager {
  Future<void> init();
  ITheme getCurrentTheme();
  bool validateListOfWidgets();
  IColorTheme get colorTheme;
  Future<void> refresh();
}
