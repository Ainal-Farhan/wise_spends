import 'package:flutter/material.dart';
import 'package:wise_spends/constant/form/form_constant.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/form_fields/th_input_number_form_fields_default.dart';

abstract class IThInputNumberFormFields extends IThWidget {
  factory IThInputNumberFormFields({
    Key? key,
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool isNegative = true,
    bool isAcceptZero = true,
    bool isPositive = true,
    FormFieldMode mode = FormConstant.formFieldModeEditable,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThInputNumberFormFieldsDefault(
        key: key,
        label: label,
        controller: controller,
        isRequired: isRequired,
        isNegative: isNegative,
        isAcceptZero: isAcceptZero,
        isPositive: isPositive,
        mode: mode,
      );
    }

    return ThInputNumberFormFieldsDefault(
      key: key,
      label: label,
      controller: controller,
      isRequired: isRequired,
      isNegative: isNegative,
      isAcceptZero: isAcceptZero,
      isPositive: isPositive,
      mode: mode,
    );
  }
}
