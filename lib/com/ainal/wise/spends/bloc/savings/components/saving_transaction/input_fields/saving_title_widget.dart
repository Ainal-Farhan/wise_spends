import 'package:flutter/material.dart';

class SavingTitleWidget extends StatelessWidget {
  final String title;

  const SavingTitleWidget({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(title);
  }
}
