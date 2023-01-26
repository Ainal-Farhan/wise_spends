import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/forms/money_storage/th_add_money_storage_form_default.dart';

abstract class IThAddMoneyStorageForm extends IThWidget {
  factory IThAddMoneyStorageForm({Key? key}) {
    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThAddMoneyStorageFormDefault(
        key: key,
      );
    }
    return ThAddMoneyStorageFormDefault(
      key: key,
    );
  }
}
