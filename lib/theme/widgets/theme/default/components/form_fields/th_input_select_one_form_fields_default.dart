import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_select_one_form_fields.dart';

class ThInputSelectOneFormFieldsDefault extends StatefulWidget
    implements IThInputSelectOneFormFields {
  final FocusNode searchFocusNode;
  final FocusNode textFieldFocusNode;
  final List<DropDownValueModel> dropDownValues;
  final Function(dynamic) onChanged;
  final bool clearOption;
  final bool searchAutofocus;
  final bool enableSearch;
  final bool searchShowCursor;
  final TextInputType searchKeyboardType;
  final SingleValueDropDownController controller;
  final bool withLabel;
  final String label;

  const ThInputSelectOneFormFieldsDefault({
    super.key,
    required this.textFieldFocusNode,
    required this.searchFocusNode,
    required this.dropDownValues,
    required this.searchKeyboardType,
    required this.onChanged,
    required this.enableSearch,
    required this.clearOption,
    required this.searchAutofocus,
    required this.searchShowCursor,
    required this.controller,
    required this.withLabel,
    required this.label,
  });

  @override
  State<ThInputSelectOneFormFieldsDefault> createState() =>
      _ThInputSelectOneFormFieldsDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThInputSelectOneFormFieldsDefaultState
    extends State<ThInputSelectOneFormFieldsDefault> {
  @override
  Widget build(BuildContext context) {
    DropDownTextField dropDownWidget = DropDownTextField(
      controller: widget.controller,
      clearOption: widget.clearOption,
      textFieldFocusNode: widget.textFieldFocusNode,
      searchFocusNode: widget.searchFocusNode,
      searchAutofocus: widget.searchAutofocus,
      dropDownItemCount: widget.dropDownValues.length,
      searchShowCursor: widget.searchShowCursor,
      enableSearch: widget.enableSearch,
      searchKeyboardType: widget.searchKeyboardType,
      dropDownList: widget.dropDownValues,
      onChanged: widget.onChanged,
    );

    return widget.withLabel
        ? Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                Text('${widget.label}: '),
                Expanded(
                  child: dropDownWidget,
                ),
              ]))
        : Expanded(child: dropDownWidget);
  }
}
