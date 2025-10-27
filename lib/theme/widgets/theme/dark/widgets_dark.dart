import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
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

class WidgetsDark extends IWidgetTheme {
  WidgetsDark._internal()
      : super([
          IThLoggedInMainTemplate,
          IThLoggedInAppbar,
          IThLoggedInDrawer,
          IThLoggedInBottomNavbar,
          IThAddSavingForm,
          IThEditSavingForm,
          IThAddMoneyStorageForm,
          IThEditMoneyStorageForm,
          IThVerticalSpacingFormFields,
          IThHorizontalSpacingFormFields,
          IThInputNumberFormFields,
          IThInputTextFormFields,
          IThInputRadioFormFields,
          IThInputSelectOneFormFields,
          IThOutputTextFormFields,
          IThOutputNumberFormFields,
          IThInputLabelFormFields,
          IThListTilesOne,
          IThBackButton,
          IThSaveButton,
          IThPlusButtonRound,
          IThBackButtonRound,
          IThErrorWidget,
        ]);
  static final WidgetsDark _widgetsDark = WidgetsDark._internal();
  factory WidgetsDark() {
    return _widgetsDark;
  }
}
