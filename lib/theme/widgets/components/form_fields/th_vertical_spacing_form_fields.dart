import 'package:flutter/material.dart';

class ThVerticalSpacingFormFields extends StatelessWidget {
  final double height;

  const ThVerticalSpacingFormFields({super.key, this.height = 16.0});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}