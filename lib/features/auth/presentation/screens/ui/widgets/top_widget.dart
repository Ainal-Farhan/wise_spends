import 'package:flutter/material.dart';
import 'dart:math' as math;

class TopWidget extends StatelessWidget {
  final double screenWidth;

  const TopWidget({super.key, required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -35 * math.pi / 180,
      child: Container(
        width: 1.2 * screenWidth,
        height: 1.2 * screenWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(150),
          gradient: const LinearGradient(
            begin: Alignment(-0.2, -0.8),
            end: Alignment.bottomCenter,
            colors: [
              Color(0x007CBFCF),
              Color(0xB316BFC4),
            ],
          ),
        ),
      ),
    );
  }
}
