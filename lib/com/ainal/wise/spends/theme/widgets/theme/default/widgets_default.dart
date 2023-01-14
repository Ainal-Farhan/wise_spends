import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/appbar/th_logged_in_appbar_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/buttons/th_back_button_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/buttons/th_save_button_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/th_logged_in_drawer_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/errors/th_error_widget_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_horizontal_spacing_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_label_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_number_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_select_one_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_text_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_input_radio_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_output_number_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_output_text_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/form_fields/th_vertical_spacing_form_fields_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/forms/saving/th_add_saving_form_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/list_tiles/th_list_tiles_one_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/navbar/th_logged_in_bottom_navbar_default.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/theme/default/components/templates/th_logged_in_main_template_default.dart';

class WidgetsDefault extends IWidgetTheme {
  WidgetsDefault()
      : super(<Type>[
          //templates
          ThLoggedInMainTemplateDefault,

          //appbar
          ThLoggedInAppbarDefault,

          //drawers
          ThLoggedInDrawerDefault,

          //navbar
          ThLoggedInBottomNavbarDefault,

          //forms
          ThAddSavingFormDefault,

          //form_fields
          ThVerticalSpacingFormFieldsDefault,
          ThHorizontalSpacingFormFieldsDefault,
          ThInputNumberFormFieldsDefault,
          ThInputTextFormFieldsDefault,
          ThInputRadioFormFieldsDefault,
          ThInputSelectOneFormFieldsDefault,
          ThOutputTextFormFieldsDefault,
          ThOutputNumberFormFieldsDefault,
          ThInputLabelFormFieldsDefault,

          //list_tiles
          ThListTilesOneDefault,

          // buttons
          ThBackButtonDefault,
          ThSaveButtonDefault,

          // errors
          ThErrorWidgetDefault,
        ]);
}
