import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_label_form_fields_default.dart';

abstract class IThInputLabelFormFields extends IThWidget {
  factory IThInputLabelFormFields({
    Key? key,
    required String text,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThInputLabelFormFieldsDefault(
        key: key,
        text: text,
      );
    }

    return ThInputLabelFormFieldsDefault(
      key: key,
      text: text,
    );
  }
}
