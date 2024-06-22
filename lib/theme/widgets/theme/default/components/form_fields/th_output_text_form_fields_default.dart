import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_text_form_fields.dart';

class ThOutputTextFormFieldsDefault extends StatelessWidget
    implements IThOutputTextFormFields {
  final String title;

  const ThOutputTextFormFieldsDefault({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
