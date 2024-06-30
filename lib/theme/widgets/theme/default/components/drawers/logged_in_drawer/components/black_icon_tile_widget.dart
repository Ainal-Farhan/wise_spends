import 'package:flutter/material.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/account_tile_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/control_tile_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/menu_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/txt.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class BlackIconTileWidget extends StatelessWidget {
  final List<MenuWidget> _menuWidgets;
  final VoidCallback _expandOrShrinkDrawer;
  final Function setSelectedItem;
  final int selectedIndex;

  const BlackIconTileWidget({
    super.key,
    required List<MenuWidget> menuWidgets,
    required VoidCallback expandOrShrinkDrawer,
    required this.setSelectedItem,
    required this.selectedIndex,
  })  : _expandOrShrinkDrawer = expandOrShrinkDrawer,
        _menuWidgets = menuWidgets;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      color: SingletonUtil.getSingleton<IManagerLocator>()!
          .getThemeManager()
          .colorTheme
          .complexDrawerBlack,
      child: Column(
        children: [
          ControlTileWidget(expandOrShrinkDrawer: _expandOrShrinkDrawer),
          Expanded(
            child: ListView.builder(
              itemCount: _menuWidgets.length,
              itemBuilder: (BuildContext context, int index) {
                MenuWidget menuWidget = _menuWidgets[index];
                bool selected = selectedIndex == index;
                return ExpansionTile(
                  onExpansionChanged: (z) => setSelectedItem(z ? index : -1),
                  leading: _menuWidgets[index],
                  title: Txt(
                    text: menuWidget.title,
                    color: Colors.white,
                  ),
                  trailing: menuWidget.submenus.isEmpty
                      ? null
                      : Icon(
                          selected
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.white,
                        ),
                  children: menuWidget.submenus,
                );
              },
            ),
          ),
          const AccountTileWidget(
            name: 'ainal',
            position: 'App Developer',
          ),
        ],
      ),
    );
  }
}
