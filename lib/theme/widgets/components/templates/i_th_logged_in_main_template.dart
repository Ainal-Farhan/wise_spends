import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_bloc.dart';
import 'package:wise_spends/constant/enum/function_enum.dart';
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
    IThLoggedInMainTemplate? thLoggedInMainTemplate;
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      thLoggedInMainTemplate = ThLoggedInMainTemplateDefault(
          key: key,
          screen: screen,
          pageRoute: pageRoute,
          bloc: bloc,
          showBottomNavBar: showBottomNavBar);
    }

    thLoggedInMainTemplate ??= ThLoggedInMainTemplateDefault(
        key: key,
        screen: screen,
        pageRoute: pageRoute,
        bloc: bloc,
        showBottomNavBar: showBottomNavBar);

    if (bloc is IBloc) {
      IBloc iBloc = bloc;
      iBloc.functionMap.addAll({
        FunctionEnum.updateAppBar: (List<dynamic>? params) =>
            thLoggedInMainTemplate?.updateAppBar()
      });
    }

    return thLoggedInMainTemplate;
  }

  void updateAppBar();
}
