import 'package:flutter/material.dart';

class ControlButtonWidget extends StatelessWidget {
  final VoidCallback _expandOrShrinkDrawer;

  const ControlButtonWidget({
    Key? key,
    required VoidCallback expandOrShrinkDrawer,
  })  : _expandOrShrinkDrawer = expandOrShrinkDrawer,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: _expandOrShrinkDrawer,
        child: Container(
          height: 45,
          alignment: Alignment.center,
          child: const FlutterLogo(
            size: 40,
          ),
        ),
      ),
    );
  }
}
