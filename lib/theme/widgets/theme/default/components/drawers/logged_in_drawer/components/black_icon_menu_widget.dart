import 'package:flutter/material.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/account_button_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/control_button_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/menu_widget.dart';
import 'package:wise_spends/util/singleton_util.dart';

class BlackIconMenuWidget extends StatelessWidget {
  final List<MenuWidget> _menuWidgets;
  final VoidCallback _expandOrShrinkDrawer;
  final Function setSelectedItem;

  const BlackIconMenuWidget(
      {super.key,
      required List<MenuWidget> menuWidgets,
      required VoidCallback expandOrShrinkDrawer,
      required this.setSelectedItem})
      : _expandOrShrinkDrawer = expandOrShrinkDrawer,
        _menuWidgets = menuWidgets;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 100,
      color: SingletonUtil.getSingleton<IManagerLocator>()!
          .getThemeManager()
          .colorTheme
          .complexDrawerBlack,
      child: Column(
        children: [
          ControlButtonWidget(expandOrShrinkDrawer: _expandOrShrinkDrawer),
          Expanded(
            child: ListView.builder(
                itemCount: _menuWidgets.length,
                itemBuilder: (contex, index) {
                  return InkWell(
                    onTap: () => setSelectedItem(index),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: _menuWidgets[index],
                    ),
                  );
                }),
          ),
          const AccountButtonWidget(),
        ],
      ),
    );
  }
}
