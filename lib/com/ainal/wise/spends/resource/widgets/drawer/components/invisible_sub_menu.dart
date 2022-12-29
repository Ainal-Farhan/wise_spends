import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/menu_list_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/menu_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/sub_menu_widget.dart';

class InvisibleSubMenuWidget extends StatelessWidget {
  final List<MenuWidget> menuWidgets;
  final bool isExpanded;
  final int selectedIndex;
  const InvisibleSubMenuWidget({
    Key? key,
    required this.menuWidgets,
    required this.selectedIndex,
    required this.isExpanded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      color: const Color.fromRGBO(0, 0, 0, 0),
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
              itemCount: menuWidgets.length,
              itemBuilder: (context, index) {
                MenuWidget menuWidget = menuWidgets[index];
                bool selected = selectedIndex == index;
                bool isValidSubMenu =
                    selected && menuWidget.submenus.isNotEmpty;
                return MenuListWidget(
                  submenus: [
                    SubMenuWidget(
                      title: menuWidget.title,
                      isTitle: true,
                    ),
                    ...menuWidget.submenus,
                  ],
                  isValidSubMenu: isValidSubMenu,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
