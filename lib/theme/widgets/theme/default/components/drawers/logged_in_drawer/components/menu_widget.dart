import 'package:flutter/material.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/sub_menu_widget.dart';

class MenuWidget extends StatelessWidget {
  final IconData iconData;
  final String title;
  final List<SubMenuWidget> submenus;
  final VoidCallback? onPressed;

  const MenuWidget({
    required this.iconData,
    required this.title,
    this.submenus = const [],
    this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData,
      color: Colors.white,
    );
  }
}
