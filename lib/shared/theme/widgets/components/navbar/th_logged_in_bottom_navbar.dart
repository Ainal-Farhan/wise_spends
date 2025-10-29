import 'package:flutter/material.dart';
import 'package:wise_spends/router/app_router.dart';

class ThLoggedInBottomNavbar extends StatelessWidget {
  final String pageRoute;
  final dynamic model;

  const ThLoggedInBottomNavbar({
    super.key,
    required this.pageRoute,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    final inactiveColor = Theme.of(context).colorScheme.primary;
    final activeColor = Colors.grey;

    final menuList = [
      {'route': AppRouter.homeLoggedInPageRoute, 'icon': Icons.home},
      {'route': AppRouter.savingsPageRoute, 'icon': Icons.money},
      {
        'route': AppRouter.viewListMoneyStoragePageRoute,
        'icon': Icons.account_balance,
      },
      {'route': AppRouter.commitmentPageRoute, 'icon': Icons.assignment},
    ];

    final List<Widget> widgetList = [];
    for (final menu in menuList) {
      final route = menu['route']! as String;
      final isActive = pageRoute == route;
      widgetList.add(
        IconButton(
          icon: Icon(menu['icon']! as IconData),
          color: isActive ? inactiveColor : activeColor,
          onPressed: () {
            if (!isActive) {
              Navigator.pushNamedAndRemoveUntil(
                context,
                route,
                (context) => false,
              );
            }
          },
        ),
      );
    }

    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: widgetList,
      ),
    );
  }
}
