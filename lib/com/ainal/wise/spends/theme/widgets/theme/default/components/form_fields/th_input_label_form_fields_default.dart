import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_input_label_form_fields.dart';

class ThInputLabelFormFieldsDefault extends StatelessWidget
    implements IThInputLabelFormFields {
  final String text;

  const ThInputLabelFormFieldsDefault({Key? key, required this.text})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
