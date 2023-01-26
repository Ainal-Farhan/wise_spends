import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/navbar/th_logged_in_bottom_navbar_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/notifiers/bottom_nav_bar_notifier.dart';

abstract class IThLoggedInBottomNavbar extends IThWidget {
  static const Map<String, int> indexBasedOnPageRoute = {
    AppRouter.homeLoggedInPageRoute: 0,
    AppRouter.savingsPageRoute: 1,
    AppRouter.viewListMoneyStoragePageRoute: 2,
    AppRouter.addMoneyStoragePageRoute: 2,
    AppRouter.editMoneyStoragePageRoute: 2,
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
