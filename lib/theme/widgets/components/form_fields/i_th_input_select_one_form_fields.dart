import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/theme/theme_list/default/default_theme.dart';
import 'package:wise_spends/theme/widgets/i_th_widget.dart';
import 'package:wise_spends/theme/widgets/i_widget_theme.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/form_fields/th_input_select_one_form_fields_default.dart';

abstract class IThInputSelectOneFormFields extends IThWidget {
  factory IThInputSelectOneFormFields({
    Key? key,
    FocusNode? textFieldFocusNode,
    FocusNode? searchFocusNode,
    List<DropDownValueModel> dropDownValues = const <DropDownValueModel>[],
    TextInputType searchKeyboardType = TextInputType.text,
    Function(dynamic)? onChanged,
    bool enableSearch = false,
    bool clearOption = false,
    bool searchAutofocus = false,
    bool searchShowCursor = false,
    SingleValueDropDownController? controller,
    bool withLabel = false,
    String label = '',
  }) {
    textFieldFocusNode = textFieldFocusNode ?? FocusNode();
    searchFocusNode = searchFocusNode ?? FocusNode();
    onChanged = onChanged ?? (dynamic) => {};
    controller = controller ?? SingleValueDropDownController();

    if (dropDownValues.isEmpty) {
      dropDownValues.add(
        const DropDownValueModel(
          name: 'No Values',
          value: null,
        ),
      );
    }

    if (IWidgetTheme.themeManager.getCurrentTheme() is DefaultTheme) {
      return ThInputSelectOneFormFieldsDefault(
        controller: controller,
        textFieldFocusNode: textFieldFocusNode,
        searchFocusNode: searchFocusNode,
        dropDownValues: dropDownValues,
        searchKeyboardType: searchKeyboardType,
        onChanged: onChanged,
        enableSearch: enableSearch,
        clearOption: clearOption,
        searchAutofocus: searchAutofocus,
        searchShowCursor: searchShowCursor,
        withLabel: withLabel,
        label: label,
      );
    }

    return ThInputSelectOneFormFieldsDefault(
      controller: controller,
      textFieldFocusNode: textFieldFocusNode,
      searchFocusNode: searchFocusNode,
      dropDownValues: dropDownValues,
      searchKeyboardType: searchKeyboardType,
      onChanged: onChanged,
      enableSearch: enableSearch,
      clearOption: clearOption,
      searchAutofocus: searchAutofocus,
      searchShowCursor: searchShowCursor,
      withLabel: withLabel,
      label: label,
    );
  }
}
