import 'package:flutter/material.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/resource/notifiers/drawer_notifier.dart';
import 'package:wise_spends/resource/ui/alert_dialog/confirm_dialog.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/black_icon_menu_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/black_icon_tile_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/invisible_sub_menu.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/menu_widget.dart';
import 'package:wise_spends/theme/widgets/theme/default/components/drawers/logged_in_drawer/components/sub_menu_widget.dart';
import 'package:wise_spends/theme/widgets/components/drawer/i_th_logged_in_drawer.dart';

class ThLoggedInDrawerDefault extends StatefulWidget
    implements IThLoggedInDrawer {
  const ThLoggedInDrawerDefault({
    super.key,
    required this.user,
  });

  final CmmnUser user;

  @override
  State<ThLoggedInDrawerDefault> createState() =>
      _ThLoggedInDrawerDefaultState();

  @override
  List<Object?> get props => [];

  @override
  bool? get stringify => null;
}

class _ThLoggedInDrawerDefaultState extends State<ThLoggedInDrawerDefault> {
  final DrawerNotifier drawerNotifier = DrawerNotifier();
  List<MenuWidget> menuWidgets = [];

  @override
  void initState() {
    super.initState();
    drawerNotifier.isExpanded = false;
    drawerNotifier.selectedIndex = -1;

    menuWidgets.clear();
    menuWidgets.addAll([
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
                    String exportedPath = await AppDatabase().exportInto();
                    if (mounted) {
                      showSnackBarMessage(
                        context,
                        "Successfully export the db into $exportedPath",
                      );
                    }
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
                    String message = await (() async {
                      try {
                        return await AppDatabase().restore()
                            ? 'Successfully'
                            : 'Failed to';
                      } catch (e) {
                        return e.toString();
                      }
                    })();

                    if (mounted) {
                      showSnackBarMessage(
                        context,
                        "$message restore the db",
                      );
                    }
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
                  currentUser: widget.user,
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
