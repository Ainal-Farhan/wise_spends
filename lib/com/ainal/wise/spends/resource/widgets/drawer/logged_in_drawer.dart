import 'dart:io';

import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/app/color_ref.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/drawer/components/txt.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/ui/snack_bar/message.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/app_path.dart';

class LoggedInDrawer extends StatefulWidget {
  const LoggedInDrawer({Key? key}) : super(key: key);

  @override
  _LoggedInDrawerState createState() => _LoggedInDrawerState();
}

class _LoggedInDrawerState extends State<LoggedInDrawer> {
  int selectedIndex = -1; //dont set it to 0

  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    cdms.add(CDM(
        iconData: Icons.backup,
        title: "Backup DB",
        onPressed: () async {
          final file = File(
              '${await AppPath().getDownloadsDirectory()}/wise_spends.sqlite');

          await AppDatabase().exportInto(file);

          showSnackBarMessage(
            context,
            "Successfully export the db into ${file.path}",
          );
        }));
    return Container(
      child: row(),
      color: const Color.fromRGBO(227, 233, 247, 0.8),
    );
  }

  Widget row() {
    return Row(children: [
      isExpanded ? blackIconTiles() : blackIconMenu(),
      invisibleSubMenus(),
    ]);
  }

  Widget blackIconTiles() {
    return Container(
      width: 200,
      color: ColorRef.complexDrawerBlack,
      child: Column(
        children: [
          controlTile(),
          Expanded(
            child: ListView.builder(
              itemCount: cdms.length,
              itemBuilder: (BuildContext context, int index) {
                //  if(index==0) return controlTile();

                CDM cdm = cdms[index];
                bool selected = selectedIndex == index;
                return ExpansionTile(
                    onExpansionChanged: (z) {
                      setState(() {
                        selectedIndex = z ? index : -1;
                      });
                    },
                    leading: cdms[index].icon,
                    title: Txt(
                      text: cdm.title,
                      color: Colors.white,
                    ),
                    trailing: cdm.submenus.isEmpty
                        ? null
                        : Icon(
                            selected
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.white,
                          ),
                    children: cdm.submenus.map((subMenu) {
                      return sMenuButton(subMenu, false);
                    }).toList());
              },
            ),
          ),
          accountTile(),
        ],
      ),
    );
  }

  Widget controlTile() {
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
        onTap: expandOrShrinkDrawer,
      ),
    );
  }

  Widget blackIconMenu() {
    return AnimatedContainer(
      duration: const Duration(seconds: 1),
      width: 100,
      color: ColorRef.complexDrawerBlack,
      child: Column(
        children: [
          controlButton(),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (contex, index) {
                  // if(index==0) return controlButton();
                  return InkWell(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: cdms[index].icon,
                    ),
                  );
                }),
          ),
          accountButton(),
        ],
      ),
    );
  }

  Widget invisibleSubMenus() {
    // List<CDM> _cmds = cdms..removeAt(0);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: isExpanded ? 0 : 125,
      color: const Color.fromRGBO(0, 0, 0, 0),
      child: Column(
        children: [
          Container(height: 95),
          Expanded(
            child: ListView.builder(
                itemCount: cdms.length,
                itemBuilder: (context, index) {
                  CDM cmd = cdms[index];
                  // if(index==0) return Container(height:95);
                  //controll button has 45 h + 20 top + 30 bottom = 95

                  bool selected = selectedIndex == index;
                  bool isValidSubMenu = selected && cmd.submenus.isNotEmpty;
                  return subMenuWidget(
                      [cmd.title, ...cmd.submenus], isValidSubMenu);
                }),
          ),
        ],
      ),
    );
  }

  Widget controlButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: InkWell(
        onTap: expandOrShrinkDrawer,
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

  Widget subMenuWidget(List<String> submenus, bool isValidSubMenu) {
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
          itemBuilder: (context, index) {
            String subMenu = submenus[index];
            return sMenuButton(subMenu, index == 0);
          }),
    );
  }

  Widget sMenuButton(String subMenu, bool isTitle) {
    return InkWell(
      onTap: () {
        //handle the function
        //if index==0? donothing: doyourlogic here
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Txt(
          text: subMenu,
          fontSize: isTitle ? 17 : 14,
          color: isTitle ? Colors.white : Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget accountButton({bool usePadding = true}) {
    return Padding(
      padding: EdgeInsets.all(usePadding ? 8 : 0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        height: 45,
        width: 45,
        decoration: BoxDecoration(
          color: Colors.white70,
          // image: Icon(Icons.person),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget accountTile() {
    return Container(
      color: ColorRef.complexDrawerBlueGrey,
      child: ListTile(
        leading: accountButton(usePadding: false),
        title: const Txt(
          text: "Prem Shanhi",
          color: Colors.white,
        ),
        subtitle: const Txt(
          text: "Web Designer",
          color: Colors.white70,
        ),
      ),
    );
  }

  List<CDM> cdms = [
    // CDM(Icons.grid_view, "Control", []),

    CDM(
      iconData: Icons.grid_view,
      title: "Dashboard",
    ),
    CDM(
      iconData: Icons.subscriptions,
      title: "Category",
      submenus: ["HTML & CSS", "Javascript", "PHP & MySQL"],
    ),
    CDM(
      iconData: Icons.markunread_mailbox,
      title: "Posts",
      submenus: ["Add", "Edit", "Delete"],
    ),
    CDM(
      iconData: Icons.pie_chart,
      title: "Analytics",
    ),
    CDM(
      iconData: Icons.trending_up,
      title: "Chart",
    ),
    CDM(
      iconData: Icons.power,
      title: "Plugins",
      submenus: ["Ad Blocker", "Everything Https", "Dark Mode"],
    ),
    CDM(
      iconData: Icons.explore,
      title: "Explore",
    ),
    CDM(
      iconData: Icons.settings,
      title: "Setting",
    ),
  ];

  void expandOrShrinkDrawer() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }
}

class CDM {
  //complex drawer menu
  final IconButton icon;
  final String title;
  final List<String> submenus;
  static void defaultOnPressed() {}

  CDM({
    required IconData iconData,
    required this.title,
    this.submenus = const [],
    VoidCallback? onPressed,
  }) : icon = IconButton(
          icon: Icon(iconData),
          onPressed: onPressed ?? defaultOnPressed,
          color: Colors.white,
        );
}
