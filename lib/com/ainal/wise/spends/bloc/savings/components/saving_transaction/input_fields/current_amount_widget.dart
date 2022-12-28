import 'package:flutter/material.dart';

class CurrentAmountWidget extends StatelessWidget {
  final double currentAmount;

  const CurrentAmountWidget({
    Key? key,
    required this.currentAmount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(currentAmount.toStringAsFixed(2));
  }
}
