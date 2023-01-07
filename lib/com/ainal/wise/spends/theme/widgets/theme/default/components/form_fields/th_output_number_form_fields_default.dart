import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/form_fields/i_th_output_number_form_fields.dart';

class ThOutputNumberFormFieldsDefault extends StatelessWidget
    implements IThOutputNumberFormFields {
  final double value;
  final int decimalPoint;

  const ThOutputNumberFormFieldsDefault({
    Key? key,
    required this.value,
    this.decimalPoint = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(value.toStringAsFixed(decimalPoint));
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
