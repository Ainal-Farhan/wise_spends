import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/txt.dart';

class ControlTileWidget extends StatelessWidget {
  final VoidCallback _expandOrShrinkDrawer;

  const ControlTileWidget({
    Key? key,
    required VoidCallback expandOrShrinkDrawer,
  })  : _expandOrShrinkDrawer = expandOrShrinkDrawer,
        super(key: key);

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
