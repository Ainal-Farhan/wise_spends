import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/app/color_ref.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/sub_menu_widget.dart';

class MenuListWidget extends StatelessWidget {
  final List<SubMenuWidget> submenus;
  final bool isValidSubMenu;
  const MenuListWidget({
    Key? key,
    required this.submenus,
    required this.isValidSubMenu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      height: isValidSubMenu ? submenus.length.toDouble() * 37.5 : 45,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isValidSubMenu
            ? ColorRef.complexDrawerBlueGrey
            : Colors.transparent,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(6),
        itemCount: isValidSubMenu ? submenus.length : 0,
        itemBuilder: (context, index) => submenus[index],
      ),
    );
  }
}
