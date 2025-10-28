import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/theme/colors/i_color_theme.dart';
import 'package:wise_spends/theme/colors/theme/default/color_default.dart';
import 'package:wise_spends/theme/colors/theme/dark/color_dark.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/theme/theme_list/i_theme.dart';
import 'package:wise_spends/constant/app/config_constant.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class SimpleTheme implements ITheme {
  final IColorTheme colorTheme;

  SimpleTheme(this.colorTheme);
}

class ThemeManager extends IThemeManager {
  final IConfigurationManager _configurationManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getConfigurationManager();
  late IColorTheme _colorTheme;

  @override
  Future<void> refresh() async {
    await init();
  }

  @override
  Future<void> init() async {
    switch (_configurationManager.getTheme()) {
      case ConfigConstant.themeDark:
        _colorTheme = ColorDark();
        break;
      default:
        _colorTheme = ColorDefault();
        break;
    }
  }

  @override
  IColorTheme get colorTheme => _colorTheme;

  @override
  ITheme getCurrentTheme() {
    // Return a simple theme object wrapping the color theme
    return SimpleTheme(_colorTheme);
  }

  @override
  bool validateListOfWidgets() {
    // Always return true since we're no longer validating widget implementations
    return true;
  }
}
