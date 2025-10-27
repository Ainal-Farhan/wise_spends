import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';

class WidgetsDark extends IWidgetTheme {
  WidgetsDark._internal() : super([]);
  static final WidgetsDark _widgetsDark = WidgetsDark._internal();
  factory WidgetsDark() {
    return _widgetsDark;
  }

  @override
  Map<String, Widget> get widgets => {};

  @override
  List<String> getMissingWidgetsFromCurrentTheme() {
    return [];
  }
}