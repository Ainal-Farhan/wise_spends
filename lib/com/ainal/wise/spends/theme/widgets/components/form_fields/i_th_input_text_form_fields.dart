import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_text_form_fields_default.dart';

abstract class IThInputTextFormFields extends IThWidget {
  factory IThInputTextFormFields({
    Key? key,
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThInputTextFormFieldsDefault(
        key: key,
        controller: controller,
        label: label,
        isRequired: isRequired,
      );
    }
    return ThInputTextFormFieldsDefault(
      key: key,
      controller: controller,
      label: label,
      isRequired: isRequired,
    );
  }
}
