import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Centered pill shown at the top of every bottom sheet to signal draggability.
class SheetDragHandle extends StatelessWidget {
  const SheetDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: WiseSpendsColors.divider,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
