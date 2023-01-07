import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/appbar/th_logged_in_appbar_default.dart';

abstract class IThLoggedInAppbar extends IThWidget {
  factory IThLoggedInAppbar({
    Key? key,
    required String loggedInUserName,
    required AnimationController colorAnimationController,
    required VoidCallback onPressed,
    required Animation colorTween,
    required Animation homeTween,
    required Animation iconTween,
    required Animation drawerTween,
    required Animation workOutTween,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThLoggedInAppbarDefault(
        loggedInUserName: loggedInUserName,
        colorAnimationController: colorAnimationController,
        onPressed: onPressed,
        colorTween: colorTween,
        homeTween: homeTween,
        iconTween: iconTween,
        drawerTween: drawerTween,
        workOutTween: workOutTween,
      );
    }

    return ThLoggedInAppbarDefault(
      loggedInUserName: loggedInUserName,
      colorAnimationController: colorAnimationController,
      onPressed: onPressed,
      colorTween: colorTween,
      homeTween: homeTween,
      iconTween: iconTween,
      drawerTween: drawerTween,
      workOutTween: workOutTween,
    );
  }
}
