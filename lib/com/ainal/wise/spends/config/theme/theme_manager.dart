import 'package:wise_spends/com/ainal/wise/spends/config/configuration/configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/i_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/default/widgets_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/app/config_constant.dart';

class ThemeManager implements IThemeManager {
  ThemeManager._internal();
  static final ThemeManager _themeManager = ThemeManager._internal();
  factory ThemeManager() {
    return _themeManager;
  }

  final IConfigurationManager _configurationManager = ConfigurationManager();
  late ITheme _currentTheme;
  late IWidgetTheme _widgetTheme;

  Future<void> refresh() async {
    await init();
  }

  @override
  Future<void> init() async {
    switch (_configurationManager.getTheme()) {
      case ConfigConstant.themeDefault:
        _currentTheme = DefaultTheme();
        _widgetTheme = WidgetsDefault();
        break;
      default:
        _currentTheme = DefaultTheme();
        _widgetTheme = WidgetsDefault();
    }

    if (!validateListOfWidgets()) {
      throw 'The Theme Widgets is incomplete';
    }
  }

  @override
  ITheme getCurrentTheme() {
    return _currentTheme;
  }

  @override
  bool validateListOfWidgets() {
    return _widgetTheme.allWidgetsAreExist();
  }
}
