import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/default/th_back_button_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_th_back_button.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_widget_theme.dart';

class WidgetsDefault implements IWidgetTheme {
  @override
  IThBackButton getThBackButton() {
    return const ThBackButtonDefault();
  }
}
