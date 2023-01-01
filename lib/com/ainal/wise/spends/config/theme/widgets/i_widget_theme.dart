import 'package:wise_spends/com/ainal/wise/spends/config/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/i_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_th_back_button.dart';

abstract class IWidgetTheme {
  Future<IThBackButton> getThBackButton() async {
    IThemeManager themeManager = ThemeManager();
    ITheme currentTheme = await themeManager.getCurrentTheme();
  }
}
