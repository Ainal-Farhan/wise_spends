import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_radio_form_fields.dart';

// ignore: must_be_immutable
class ThInputRadioFormFieldsDefault extends StatefulWidget
    implements IThInputRadioFormFields {
  String value;
  final List<String> optionsList;
  final Function setValueFunc;
  final bool isInline;
  final String label;

  ThInputRadioFormFieldsDefault({
    Key? key,
    required this.setValueFunc,
    required this.optionsList,
    required this.isInline,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  State<ThInputRadioFormFieldsDefault> createState() =>
      _ThInputRadioFormFieldsDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThInputRadioFormFieldsDefaultState
    extends State<ThInputRadioFormFieldsDefault> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text('${widget.label}: '),
          Expanded(
            child: RadioGroup<String>.builder(
              horizontalAlignment: MainAxisAlignment.spaceAround,
              direction: widget.isInline ? Axis.horizontal : Axis.vertical,
              groupValue: widget.value,
              onChanged: (value) => setState(() {
                widget.value = value ?? '';
                widget.setValueFunc(value);
              }),
              items: widget.optionsList,
              itemBuilder: (item) => RadioButtonBuilder(
                item,
              ),
              fillColor: Colors.purple,
              activeColor: Colors.amber,
            ),
          ),
        ],
      ),
    );
  }
}
