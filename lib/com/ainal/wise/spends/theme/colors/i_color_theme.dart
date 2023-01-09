import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/colors/theme/default/color_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_manager.dart';

abstract class IColorTheme {
  Color get primaryColor;
  Color get timerBlue;

  Color get backgroundBlue;

  Color get accountPurple;

  Color get currenciesPageBackground;
  Color get currenciesNameColor;
  Color get currencyPositiveGreen;
  Color get currencyIndicatorColor;

  Color get sendMoneyBlue;

  Color get googlResultsGrey;

  Color get compexDrawerCanvasColor;
  Color get complexDrawerBlack;
  Color get complexDrawerBlueGrey;

  //interlaced dashboard
  Color get interlacedBackground;
  Color get interlacedAvatarBorderBlue;
  Color get interlacedChatPurple;

  //richCalculator
  Color get richCalculatorCanvas;
  Color get richCalculatorOutterButtonColor;
  Color get richCalculatorInnerButtonColor;
  Color get richCalculatorYellowButtonColor;

  //buttonExample
  Color get buttonExampleCanvas;
  Color get buttonSampleColor;

  ///Expandile
  Color get iphone12Purple;

  ///DoubleCard
  Color get doubleCardBlue;

  static final IThemeManager themeManager = ThemeManager();

  factory IColorTheme() {
    if (themeManager.getCurrentTheme() is DefaultTheme) {
      return ColorDefault();
    }
    return ColorDefault();
  }
}
