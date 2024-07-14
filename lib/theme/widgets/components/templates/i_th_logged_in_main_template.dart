import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/templates/th_logged_in_main_template_default.dart';

abstract class IThLoggedInMainTemplate extends IThWidget {
  factory IThLoggedInMainTemplate({
    Key? key,
    required StatefulWidget screen,
    required String pageRoute,
    required Bloc bloc,
    List<FloatingActionButton> floatingActionButtons =
        const <FloatingActionButton>[],
    bool showBottomNavBar = true,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThLoggedInMainTemplateDefault(
          key: key,
          screen: screen,
          pageRoute: pageRoute,
          bloc: bloc,
          showBottomNavBar: showBottomNavBar);
    }

    return ThLoggedInMainTemplateDefault(
        key: key,
        screen: screen,
        pageRoute: pageRoute,
        bloc: bloc,
        showBottomNavBar: showBottomNavBar);
  }
}
