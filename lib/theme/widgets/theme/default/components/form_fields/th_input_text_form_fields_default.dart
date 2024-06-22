import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/components/form_fields/i_th_input_text_form_fields.dart';

class ThInputTextFormFieldsDefault extends StatelessWidget
    implements IThInputTextFormFields {
  final TextEditingController controller;
  final String label;
  final bool isRequired;

  const ThInputTextFormFieldsDefault({
    super.key,
    required this.controller,
    required this.label,
    this.isRequired = false,
  });

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
            return 'Please enter the saving name';
          }
          return null;
        },
        keyboardType: TextInputType.text,
      ),
    );
  }

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}
