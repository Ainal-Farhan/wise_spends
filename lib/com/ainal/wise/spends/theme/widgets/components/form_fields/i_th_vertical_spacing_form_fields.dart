import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_vertical_spacing_form_fields_default.dart';

abstract class IThVerticalSpacingFormFields extends IThWidget {
  factory IThVerticalSpacingFormFields({
    Key? key,
    required double height,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThVerticalSpacingFormFieldsDefault(
        key: key,
        height: height,
      );
    }

    return ThVerticalSpacingFormFieldsDefault(
      key: key,
      height: height,
    );
  }
}
