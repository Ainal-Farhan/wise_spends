import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/colors/i_color_theme.dart';

class ColorDefault implements IColorTheme {
  ColorDefault._internal();
  static final ColorDefault _colorDefault = ColorDefault._internal();
  factory ColorDefault() {
    return _colorDefault;
  }

  static const Color _primaryColor = Color(0xff5b60ec);
  static const Color _backgroundBlue = Color(0xff1b81f1);

  static const Color _complexDrawerCanvasColor = Color(0xffe3e9f7);
  static const Color _complexDrawerBlack = Color(0xff11111d);
  static const Color _complexDrawerBlueGrey = Color(0xff1d1b31);

  @override
  Color get primaryColor => _primaryColor;

  @override
  Color get backgroundBlue => _backgroundBlue;

  @override
  Color get complexDrawerCanvasColor => _complexDrawerCanvasColor;
  @override
  Color get complexDrawerBlack => _complexDrawerBlack;
  @override
  Color get complexDrawerBlueGrey => _complexDrawerBlueGrey;
}
