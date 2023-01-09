import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/colors/i_color_theme.dart';

class ColorDefault implements IColorTheme {
  ColorDefault._internal();
  static final ColorDefault _colorDefault = ColorDefault._internal();
  factory ColorDefault() {
    return _colorDefault;
  }

  @override
  Color get primaryColor => const Color(0xff5b60ec);
  @override
  Color get timerBlue => const Color(0xff1c77dd);

  @override
  Color get backgroundBlue => const Color(0xff1b81f1);

  @override
  Color get accountPurple => primaryColor;

  @override
  Color get currenciesPageBackground => const Color(0xff0f1e4e);
  @override
  Color get currenciesNameColor => const Color(0xff7080b3);
  @override
  Color get currencyPositiveGreen => const Color(0xff0eff7e);
  @override
  Color get currencyIndicatorColor => const Color(0xff6170f3);

  @override
  Color get sendMoneyBlue => const Color(0xff4285f4);

  @override
  Color get googlResultsGrey => const Color(0xffeff4f2);

  @override
  Color get compexDrawerCanvasColor => const Color(0xffe3e9f7);
  @override
  Color get complexDrawerBlack => const Color(0xff11111d);
  @override
  Color get complexDrawerBlueGrey => const Color(0xff1d1b31);

  //interlaced dashboard
  @override
  Color get interlacedBackground => const Color(0xfff7f8fa);
  @override
  Color get interlacedAvatarBorderBlue => const Color(0xff2554fc);
  @override
  Color get interlacedChatPurple => const Color(0xff8532fb);

  //richCalculator

  @override
  Color get richCalculatorCanvas => const Color(0xff222433);
  @override
  Color get richCalculatorOutterButtonColor => const Color(0xff333549);
  @override
  Color get richCalculatorInnerButtonColor => const Color(0xff2c2e41);
  @override
  Color get richCalculatorYellowButtonColor =>
      const Color.fromARGB(255, 251, 184, 1);

  //buttonExample
  @override
  Color get buttonExampleCanvas => const Color(0xfff3f6ff);
  @override
  Color get buttonSampleColor => const Color(0xff7c2ae8);
  @override
  Color get doubleCardBlue => const Color(0xff045bd8);
  @override
  Color get iphone12Purple => const Color(0xffB8AFE6);
}
