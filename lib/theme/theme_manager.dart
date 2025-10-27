import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/theme/colors/i_color_theme.dart';
import 'package:wise_spends/theme/colors/theme/default/color_default.dart';
import 'package:wise_spends/theme/colors/theme/dark/color_dark.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/theme_list/dark/dark_theme.dart';
import 'package:wise_spends/theme/theme_list/i_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/widgets_default.dart';
import 'package:wise_spends/theme/widgets/theme/dark/widgets_dark.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/constant/app/config_constant.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class ThemeManager extends IThemeManager {
  final IConfigurationManager _configurationManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getConfigurationManager();
  late ITheme _currentTheme;
  late IWidgetTheme _widgetTheme;
  late IColorTheme _colorTheme;

  @override
  Future<void> refresh() async {
    await init();
  }

  @override
  Future<void> init() async {
    switch (_configurationManager.getTheme()) {
      case ConfigConstant.themeDefault:
        _currentTheme = DefaultTheme();
        _widgetTheme = WidgetsDefault();
        _colorTheme = ColorDefault();
        break;
      case ConfigConstant.themeDark:
        _currentTheme = DarkTheme();
        _widgetTheme = WidgetsDark();
        _colorTheme = ColorDark();
        break;
      default:
        _currentTheme = DefaultTheme();
        _widgetTheme = WidgetsDefault();
        _colorTheme = ColorDefault();
    }

    List<String> missingWidgetsFromCurrentTheme =
        _widgetTheme.getMissingWidgetsFromCurrentTheme();

    if (missingWidgetsFromCurrentTheme.isNotEmpty) {
      throw 'required missing widgets = $missingWidgetsFromCurrentTheme';
    }
  }

  @override
  ITheme getCurrentTheme() {
    return _currentTheme;
  }

  @override
  bool validateListOfWidgets() {
    return _widgetTheme.getMissingWidgetsFromCurrentTheme().isEmpty;
  }

  @override
  IColorTheme get colorTheme => _colorTheme;
}
