import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/notifiers/drawer_notifier.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/black_icon_menu_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/black_icon_tile_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/invisible_sub_menu.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/menu_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/sub_menu_widget.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/ui/snack_bar/message.dart';

class LoggedInDrawer extends StatefulWidget {
  const LoggedInDrawer({
    Key? key,
  }) : super(key: key);

  @override
  State<LoggedInDrawer> createState() => _LoggedInDrawerState();
}

class _LoggedInDrawerState extends State<LoggedInDrawer> {
  final DrawerNotifier drawerNotifier = DrawerNotifier();
  List<MenuWidget> menuWidgets = [];

  @override
  void initState() {
    super.initState();
    drawerNotifier.isExpanded = false;
    drawerNotifier.selectedIndex = -1;

    menuWidgets.clear();
    menuWidgets.addAll([
      const MenuWidget(
        iconData: Icons.grid_view,
        title: "Dashboard",
      ),
      const MenuWidget(
        iconData: Icons.pie_chart,
        title: "Analytics",
      ),
      const MenuWidget(
        iconData: Icons.trending_up,
        title: "Chart",
      ),
      const MenuWidget(
        iconData: Icons.power,
        title: "Plugins",
        submenus: <SubMenuWidget>[
          SubMenuWidget(title: "Ad Blocker"),
          SubMenuWidget(title: "Dark Mod"),
        ],
      ),
      const MenuWidget(
        iconData: Icons.explore,
        title: "Explore",
      ),
      const MenuWidget(
        iconData: Icons.settings,
        title: "Setting",
      ),
      MenuWidget(
        iconData: Icons.book_online_outlined,
        title: "Database",
        submenus: <SubMenuWidget>[
          SubMenuWidget(
              title: 'Backup DB',
              onTap: () {
                showConfirmDialog(
                  context: context,
                  message: "Backup database?",
                  onConfirm: () async {
                    showSnackBarMessage(
                      context,
                      "Successfully export the db into ${await AppDatabase().exportInto()}",
                    );
                  },
                );
              }),
          SubMenuWidget(
              title: 'Restore DB',
              onTap: () {
                showConfirmDialog(
                  context: context,
                  message: "Restore database?",
                  onConfirm: () async {
                    showSnackBarMessage(
                      context,
                      "${await (() async {
                        try {
                          return await AppDatabase().restore()
                              ? 'Successfully'
                              : 'Failed to';
                        } catch (e) {
                          return e.toString();
                        }
                      })()} restore the db",
                    );
                  },
                );
              }),
        ],
      )
    ]);
  }

  void expandOrShrinkDrawer() {
    setState(() {
      drawerNotifier.isExpanded = !drawerNotifier.isExpanded;
    });
  }

  void setSelectedItem(int index) {
    setState(() {
      drawerNotifier.selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromRGBO(227, 233, 247, 0.8),
      child: Row(
        children: [
          drawerNotifier.isExpanded
              ? BlackIconTileWidget(
                  menuWidgets: menuWidgets,
                  expandOrShrinkDrawer: expandOrShrinkDrawer,
                  setSelectedItem: setSelectedItem,
                  selectedIndex: drawerNotifier.selectedIndex,
                )
              : BlackIconMenuWidget(
                  menuWidgets: menuWidgets,
                  expandOrShrinkDrawer: expandOrShrinkDrawer,
                  setSelectedItem: setSelectedItem,
                ),
          InvisibleSubMenuWidget(
            isExpanded: drawerNotifier.isExpanded,
            menuWidgets: menuWidgets,
            selectedIndex: drawerNotifier.selectedIndex,
          ),
        ],
      ),
    );
  }
}
