import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/forms/saving/th_add_saving_form_default.dart';

abstract class IThAddSavingForm extends IThWidget {
  factory IThAddSavingForm({
    Key? key,
    required List<DropDownValueModel> moneyStorageList,
    required List<DropDownValueModel> savingTypeList,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThAddSavingFormDefault(
        key: key,
        moneyStorageList: moneyStorageList,
        savingTypeList: savingTypeList,
      );
    }
    return ThAddSavingFormDefault(
      key: key,
      moneyStorageList: moneyStorageList,
      savingTypeList: savingTypeList,
    );
  }
}
