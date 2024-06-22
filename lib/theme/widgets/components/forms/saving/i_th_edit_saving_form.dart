import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/forms/saving/th_edit_saving_form_default.dart';

abstract class IThEditSavingForm extends IThWidget {
  factory IThEditSavingForm(
      {Key? key,
      required SvngSaving saving,
      required List<DropDownValueModel> moneyStorageList,
      required List<DropDownValueModel> savingTypeList}) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThEditSavingFormDefault(
        key: key,
        saving: saving,
        moneyStorageList: moneyStorageList,
        savingTypeList: savingTypeList,
      );
    }
    return ThEditSavingFormDefault(
      key: key,
      saving: saving,
      moneyStorageList: moneyStorageList,
      savingTypeList: savingTypeList,
    );
  }
}
