import 'package:flutter/material.dart';

Widget saveSavingInputField(
    {BuildContext? context, required VoidCallback onTap}) {
  return GestureDetector(
    child: Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Text(
            'Save',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    ),
    onTap: onTap,
  );
}
