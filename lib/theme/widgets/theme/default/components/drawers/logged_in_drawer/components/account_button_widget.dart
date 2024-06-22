import 'package:flutter/material.dart';

class AccountButtonWidget extends StatelessWidget {
  final bool usePadding;

  const AccountButtonWidget({
    this.usePadding = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(usePadding ? 8 : 0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.white70,
          // image: Icon(Icons.person),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}
