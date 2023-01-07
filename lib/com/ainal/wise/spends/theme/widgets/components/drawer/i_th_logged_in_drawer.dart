import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/th_logged_in_drawer_default.dart';

abstract class IThLoggedInDrawer extends IThWidget {
  factory IThLoggedInDrawer({Key? key}) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThLoggedInDrawerDefault(
        key: key,
      );
    }

    return ThLoggedInDrawerDefault(
      key: key,
    );
  }
}
