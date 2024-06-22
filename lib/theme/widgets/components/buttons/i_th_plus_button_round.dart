import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/buttons/th_plus_button_round_default.dart';

abstract class IThPlusButtonRound extends IThWidget {
  factory IThPlusButtonRound({
    Key? key,
    Function()? onTap,
  }) {
    onTap = onTap ?? () => {};

    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThPlusButtonRoundDefault(
        onTap: onTap,
      );
    }
    return ThPlusButtonRoundDefault(
      onTap: onTap,
    );
  }
}
