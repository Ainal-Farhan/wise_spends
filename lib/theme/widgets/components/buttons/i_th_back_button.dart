import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/buttons/th_back_button_default.dart';

abstract class IThBackButton extends IThWidget {
  factory IThBackButton({Key? key}) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return const ThBackButtonDefault();
    }
    return const ThBackButtonDefault();
  }
}
