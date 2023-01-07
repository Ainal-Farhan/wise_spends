import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_radio_form_fields_default.dart';

abstract class IThInputRadioFormFields extends IThWidget {
  factory IThInputRadioFormFields({
    Key? key,
    required Function setValueFunc,
    required List<String> optionsList,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThInputRadioFormFieldsDefault(
        key: key,
        setValueFunc: setValueFunc,
        optionsList: optionsList,
      );
    }

    return ThInputRadioFormFieldsDefault(
      key: key,
      setValueFunc: setValueFunc,
      optionsList: optionsList,
    );
  }
}
