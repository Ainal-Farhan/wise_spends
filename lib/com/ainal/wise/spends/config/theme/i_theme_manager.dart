import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/i_theme.dart';

abstract class IThemeManager {
  Future<ITheme> getCurrentTheme();
}
