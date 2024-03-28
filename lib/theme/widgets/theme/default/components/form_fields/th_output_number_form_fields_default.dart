import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_output_number_form_fields.dart';

class ThOutputNumberFormFieldsDefault extends StatelessWidget
    implements IThOutputNumberFormFields {
  final double value;
  final int decimalPoint;
  final String prefix;
  final String postfix;

  const ThOutputNumberFormFieldsDefault({
    Key? key,
    required this.value,
    required this.decimalPoint,
    required this.prefix,
    required this.postfix,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(prefix + value.toStringAsFixed(decimalPoint) + postfix);
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
