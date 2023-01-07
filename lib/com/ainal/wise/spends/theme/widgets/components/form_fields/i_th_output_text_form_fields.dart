import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_output_text_form_fields_default.dart';

abstract class IThOutputTextFormFields extends IThWidget {
  factory IThOutputTextFormFields({
    Key? key,
    required String title,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThOutputTextFormFieldsDefault(
        key: key,
        title: title,
      );
    }

    return ThOutputTextFormFieldsDefault(
      key: key,
      title: title,
    );
  }
}
