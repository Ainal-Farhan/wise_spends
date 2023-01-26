import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/forms/money_storage/th_edit_money_storage_form_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/vo/impl/money_storage/edit_money_storage_form_vo.dart';

abstract class IThEditMoneyStorageForm extends IThWidget {
  factory IThEditMoneyStorageForm({
    Key? key,
    required EditMoneyStorageFormVO editMoneyStorageFormVO,
  }) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThEditMoneyStorageFormDefault(
        key: key,
        editMoneyStorageFormVO: editMoneyStorageFormVO,
      );
    }
    return ThEditMoneyStorageFormDefault(
      key: key,
      editMoneyStorageFormVO: editMoneyStorageFormVO,
    );
  }
}
