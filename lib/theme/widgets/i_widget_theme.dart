import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/theme/widgets/components/appbar/i_th_logged_in_appbar.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_back_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_plus_button_round.dart';
import 'package:wise_spends/theme/widgets/components/buttons/i_th_save_button.dart';
import 'package:wise_spends/theme/widgets/components/drawer/i_th_logged_in_drawer.dart';
import 'package:wise_spends/theme/widgets/components/errors/i_th_error_widget.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_horizontal_spacing_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_label_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_radio_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_number_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_text_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_vertical_spacing_form_fields.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_add_money_storage_form.dart';
import 'package:wise_spends/theme/widgets/components/forms/money_storage/i_th_edit_money_storage_form.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/i_th_add_saving_form.dart';
import 'package:wise_spends/theme/widgets/components/forms/saving/i_th_edit_saving_form.dart';
import 'package:wise_spends/theme/widgets/components/list_tiles/i_th_list_tiles_one.dart';
import 'package:wise_spends/theme/widgets/components/navbar/i_th_logged_in_bottom_navbar.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

abstract class IWidgetTheme {
  static final IThemeManager themeManager = IThemeManager();
  static final List<Type> widgetThemeList = List.unmodifiable([
    //templates
    IThLoggedInMainTemplate,

    //appbar
    IThLoggedInAppbar,

    //drawers
    IThLoggedInDrawer,

    //navbar
    IThLoggedInBottomNavbar,

    //forms
    IThAddSavingForm,
    IThEditSavingForm,
    IThAddMoneyStorageForm,
    IThEditMoneyStorageForm,

    //form_fields
    IThVerticalSpacingFormFields,
    IThHorizontalSpacingFormFields,
    IThInputNumberFormFields,
    IThInputTextFormFields,
    IThInputRadioFormFields,
    IThInputSelectOneFormFields,
    IThOutputTextFormFields,
    IThOutputNumberFormFields,
    IThInputLabelFormFields,

    //list_tiles
    IThListTilesOne,

    //buttons
    IThBackButton,
    IThSaveButton,
    IThPlusButtonRound,
    IThBackButtonRound,

    // errors
    IThErrorWidget,
  ]);

  final List<Type> currentWidgetThemeList;

  IWidgetTheme(List<Type> currentWidgetThemeList)
      : currentWidgetThemeList = List.unmodifiable(currentWidgetThemeList);

  dynamic getMissingWidgetsFromCurrentTheme() {
    List<String> missingWidgets = [];

    for (Type requiredWidgetType in IWidgetTheme.widgetThemeList) {
      if (currentWidgetThemeList.indexWhere((currentWidgetType) =>
              currentWidgetType
                  .toString()
                  .contains(requiredWidgetType.toString().substring(1))) ==
          -1) {
        missingWidgets.add(requiredWidgetType.toString());
      }
    }

    return missingWidgets;
  }
}

class _TypeHelper<T> {}

bool isSubtypeOf<S, T>() => _TypeHelper<S>() is _TypeHelper<T>;
