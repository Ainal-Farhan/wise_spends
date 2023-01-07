import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_output_text_form_fields.dart';

class ThOutputTextFormFieldsDefault extends StatelessWidget
    implements IThOutputTextFormFields {
  final String title;

  const ThOutputTextFormFieldsDefault({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
