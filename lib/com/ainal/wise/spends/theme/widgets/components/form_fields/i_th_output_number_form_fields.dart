import 'package:flutter/cupertino.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_output_number_form_fields_default.dart';

abstract class IThOutputNumberFormFields extends IThWidget {
  factory IThOutputNumberFormFields({
    Key? key,
    required double value,
    int decimalPoint = 0,
    String prefix = '',
    String postfix = '',
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThOutputNumberFormFieldsDefault(
        key: key,
        value: value,
        decimalPoint: decimalPoint,
        prefix: prefix,
        postfix: postfix,
      );
    }
    return ThOutputNumberFormFieldsDefault(
      key: key,
      value: value,
      decimalPoint: decimalPoint,
      prefix: prefix,
      postfix: postfix,
    );
  }
}
