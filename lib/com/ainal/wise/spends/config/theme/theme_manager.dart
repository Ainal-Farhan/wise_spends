import 'package:wise_spends/com/ainal/wise/spends/config/configuration/configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/i_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/app/config_constant.dart';

class ThemeManager implements IThemeManager {
  ThemeManager._internal();
  static final ThemeManager _themeManager = ThemeManager._internal();
  factory ThemeManager() {
    return _themeManager;
  }

  final IConfigurationManager _configurationManager = ConfigurationManager();
  late ITheme _currentTheme;

  Future<void> _init() async {
    switch (await _configurationManager.getTheme()) {
      case ConfigConstant.themeDefault:
        _currentTheme = DefaultTheme();
        break;
      default:
        _currentTheme = DefaultTheme();
    }
  }

  Future<void> _refresh() async {
    await _init();
  }

  @override
  Future<ITheme> getCurrentTheme() async {
    await _refresh();
    return _currentTheme;
  }
}
