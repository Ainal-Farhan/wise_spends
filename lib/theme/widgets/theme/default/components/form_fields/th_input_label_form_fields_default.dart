import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_label_form_fields.dart';

class ThInputLabelFormFieldsDefault extends StatelessWidget
    implements IThInputLabelFormFields {
  final String text;

  const ThInputLabelFormFieldsDefault({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
