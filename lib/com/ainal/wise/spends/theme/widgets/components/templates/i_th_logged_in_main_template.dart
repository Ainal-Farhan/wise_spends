import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/templates/th_logged_in_main_template_default.dart';

abstract class IThLoggedInMainTemplate extends IThWidget {
  factory IThLoggedInMainTemplate({
    Key? key,
    required StatefulWidget screen,
    required String pageRoute,
    required Bloc bloc,
    List<FloatingActionButton> floatingActionButtons =
        const <FloatingActionButton>[],
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThLoggedInMainTemplateDefault(
        key: key,
        screen: screen,
        pageRoute: pageRoute,
        bloc: bloc,
      );
    }
    return ThLoggedInMainTemplateDefault(
      key: key,
      screen: screen,
      pageRoute: pageRoute,
      bloc: bloc,
    );
  }
}
