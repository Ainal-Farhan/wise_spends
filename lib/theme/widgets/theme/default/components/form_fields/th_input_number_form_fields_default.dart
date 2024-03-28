import 'package:flutter/material.dart';
import 'package:wise_spends/constant/form/form_constant.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_number_form_fields.dart';

class ThInputNumberFormFieldsDefault extends StatelessWidget
    implements IThInputNumberFormFields {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final bool isNegative;
  final bool isAcceptZero;
  final bool isPositive;
  final FormFieldMode mode;

  const ThInputNumberFormFieldsDefault({
    Key? key,
    required this.label,
    required this.controller,
    required this.isRequired,
    required this.isNegative,
    required this.isAcceptZero,
    required this.isPositive,
    required this.mode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontSize: 20,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        style: const TextStyle(
          fontSize: 20,
        ),
        validator: (value) {
          if (isRequired && value!.isEmpty) {
            return 'Please enter the amount';
          }
          if (value!.isEmpty) {
            if (double.tryParse(value) == null) {
              return 'Please enter a valid amount';
            } else if (double.parse(value) < 0) {
              return 'Please enter a positive amount';
            }
          }
          return null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
