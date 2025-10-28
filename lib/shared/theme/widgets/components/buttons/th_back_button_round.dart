import 'package:flutter/material.dart';

class ThBackButtonRound extends StatelessWidget {
  final VoidCallback onTap;

  const ThBackButtonRound({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: 'back_button_round',
      onPressed: onTap,
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.arrow_back),
    );
  }
}