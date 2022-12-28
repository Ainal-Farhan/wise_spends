import 'package:flutter/material.dart';

class CurrentAmountWidget extends StatelessWidget {
  final TextEditingController controller;
  const CurrentAmountWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Initial Amount',
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
        if (value!.isEmpty) {
          return 'Please enter the amount';
        }
        if (double.tryParse(value) == null) {
          return 'Please enter a valid amount';
        } else if (double.parse(value) < 0) {
          return 'Please enter a positive amount';
        }
        return null;
      },
      keyboardType: TextInputType.number,
    );
  }
}
