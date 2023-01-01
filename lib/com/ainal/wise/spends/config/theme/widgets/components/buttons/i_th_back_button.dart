import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/default/buttons/th_back_button_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/theme/widgets/i_widget_theme.dart';

abstract class IThBackButton extends Equatable implements Widget {
  factory IThBackButton({Key? key}) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return const ThBackButtonDefault();
    }
    return const ThBackButtonDefault();
  }
}
