import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/buttons/th_save_button_default.dart';

abstract class IThSaveButton extends IThWidget {
  factory IThSaveButton({
    Key? key,
    required VoidCallback onTap,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThSaveButtonDefault(
        key: key,
        onTap: onTap,
      );
    }

    return ThSaveButtonDefault(
      key: key,
      onTap: onTap,
    );
  }
}
