import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/txt.dart';

class ControlTileWidget extends StatelessWidget {
  final VoidCallback _expandOrShrinkDrawer;

  const ControlTileWidget({
    super.key,
    required VoidCallback expandOrShrinkDrawer,
  })  : _expandOrShrinkDrawer = expandOrShrinkDrawer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: ListTile(
        leading: const FlutterLogo(),
        title: const Txt(
          text: "Wise Spends",
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        onTap: _expandOrShrinkDrawer,
      ),
    );
  }
}
