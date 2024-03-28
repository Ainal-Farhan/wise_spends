import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/errors/th_error_widget_default.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';

abstract class IThErrorWidget extends IThWidget {
  factory IThErrorWidget({
    Key? key,
    required String errorMessage,
    VoidCallback? onPressed,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThErrorWidgetDefault(
        errorMessage: errorMessage,
        onPressed: onPressed,
      );
    }
    return ThErrorWidgetDefault(
      errorMessage: errorMessage,
      onPressed: onPressed,
    );
  }
}
