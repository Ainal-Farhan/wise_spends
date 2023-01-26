import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/forms/saving/th_add_saving_form_default.dart';

abstract class IThAddSavingForm extends IThWidget {
  factory IThAddSavingForm({
    Key? key,
    required Function eventLoader,
    required List<DropDownValueModel> moneyStorageList,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThAddSavingFormDefault(
        key: key,
        eventLoader: eventLoader,
        moneyStorageList: moneyStorageList,
      );
    }
    return ThAddSavingFormDefault(
      key: key,
      eventLoader: eventLoader,
      moneyStorageList: moneyStorageList,
    );
  }
}
