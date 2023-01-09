import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/colors/theme/default/color_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_manager.dart';

abstract class IColorTheme {
  Color get primaryColor;

  Color get backgroundBlue;

  Color get complexDrawerCanvasColor;
  Color get complexDrawerBlack;
  Color get complexDrawerBlueGrey;

  static final IThemeManager themeManager = ThemeManager();

  factory IColorTheme() {
    if (themeManager.getCurrentTheme() is DefaultTheme) {
      return ColorDefault();
    }
    return ColorDefault();
  }
}
