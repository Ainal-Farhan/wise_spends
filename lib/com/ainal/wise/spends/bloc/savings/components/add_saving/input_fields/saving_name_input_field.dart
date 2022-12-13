import 'package:flutter/material.dart';

Widget savingNameInputField(TextEditingController controller) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Saving Name',
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
          return 'Please enter the saving name';
        }
        return null;
      },
      keyboardType: TextInputType.text,
    ),
  );
}
