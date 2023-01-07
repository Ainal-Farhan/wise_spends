import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_horizontal_spacing_form_fields_default.dart';

abstract class IThHorizontalSpacingFormFields extends IThWidget {
  factory IThHorizontalSpacingFormFields({
    Key? key,
    required double width,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThHorizontalSpacingFormFieldsDefault(
        width: width,
        key: key,
      );
    }
    return ThHorizontalSpacingFormFieldsDefault(
      width: width,
      key: key,
    );
  }
}
