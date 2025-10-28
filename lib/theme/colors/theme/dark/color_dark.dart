import 'package:flutter/material.dart';
import 'package:wise_spends/theme/colors/i_color_theme.dart';

class ColorDark implements IColorTheme {
  ColorDark._internal();
  static final ColorDark _colorDark = ColorDark._internal();
  factory ColorDark() {
    return _colorDark;
  }

  static const Color _primaryColor = Color(0xff6c63ff);
  static const Color _backgroundBlue = Color(0xff2d2b55);

  static const Color _complexDrawerCanvasColor = Color(0xff1e1e2e);
  static const Color _complexDrawerBlack = Color(0xfff8f8f2);  // This is actually light gray/white
  static const Color _complexDrawerBlueGrey = Color(0xff44475a);

  @override
  Color get primaryColor => _primaryColor;

  @override
  Color get backgroundBlue => _backgroundBlue;

  @override
  Color get complexDrawerCanvasColor => _complexDrawerCanvasColor;
  
  @override
  Color get complexDrawerBlack => _complexDrawerBlack;  // Light text for contrast
  
  @override
  Color get complexDrawerBlueGrey => _complexDrawerBlueGrey;
}