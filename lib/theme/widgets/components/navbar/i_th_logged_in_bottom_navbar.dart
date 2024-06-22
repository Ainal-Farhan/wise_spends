import 'package:flutter/material.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/navbar/th_logged_in_bottom_navbar_default.dart';
import 'package:wise_spends/resource/notifiers/bottom_nav_bar_notifier.dart';

abstract class IThLoggedInBottomNavbar extends IThWidget {
  static const Map<String, int> indexBasedOnPageRoute = {
    // AppRouter.homeLoggedInPageRoute: -1,
    AppRouter.savingsPageRoute: 0,
    AppRouter.viewListMoneyStoragePageRoute: 1,
    AppRouter.addMoneyStoragePageRoute: 1,
    AppRouter.editMoneyStoragePageRoute: 1,
  };

  factory IThLoggedInBottomNavbar({
    Key? key,
    required String pageRoute,
    required BottomNavBarNotifier model,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThLoggedInBottomNavbarDefault(
        key: key,
        model: model,
        pageRoute: pageRoute,
      );
    }

    return ThLoggedInBottomNavbarDefault(
      key: key,
      model: model,
      pageRoute: pageRoute,
    );
  }
}
