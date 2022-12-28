import 'package:flutter/material.dart';

class TransactionAmountWidget extends StatelessWidget {
  final TextEditingController controller;
  const TransactionAmountWidget({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: 'Transaction Amount',
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
            return 'Please enter the amount for the transaction';
          }
          if (double.tryParse(value) == null) {
            return 'Please enter a valid amount for the transaction';
          } else if (double.parse(value) < 0) {
            return 'Please enter a positive amount for the transaction';
          }
          return null;
        },
        keyboardType: TextInputType.number,
      ),
    );
  }
}
