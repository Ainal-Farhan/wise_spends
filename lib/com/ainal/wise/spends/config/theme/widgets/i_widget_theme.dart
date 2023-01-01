import 'package:wise_spends/com/ainal/wise/spends/config/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/components/buttons/i_th_back_button.dart';

abstract class IWidgetTheme {
  static final IThemeManager themeManager = ThemeManager();
  static final List<Type> widgetThemeList = List.unmodifiable([
    IThBackButton,
  ]);

  final List<Type> currentWidgetThemeList;

  IWidgetTheme(List<Type> currentWidgetThemeList)
      : currentWidgetThemeList = List.unmodifiable(currentWidgetThemeList);

  bool allWidgetsAreExist() {
    if (IWidgetTheme.widgetThemeList.length != currentWidgetThemeList.length) {
      return false;
    }
    for (int i = 0; i < IWidgetTheme.widgetThemeList.length; i++) {
      if (IWidgetTheme.widgetThemeList[i] == currentWidgetThemeList[i]) {
        return false;
      }
    }
    return true;
  }
}
