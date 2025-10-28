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
    return BottomAppBar(
      color: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            color: pageRoute.contains('home')
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.homeLoggedInPageRoute,
              (context) => false,
            ),
          ),
          IconButton(
            icon: Icon(Icons.money),
            color: pageRoute.contains('savings')
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.savingsPageRoute,
              (context) => false,
            ),
          ),
          IconButton(
            icon: Icon(Icons.account_balance),
            color: pageRoute.contains('money_storage')
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.viewListMoneyStoragePageRoute,
              (context) => false,
            ),
          ),
          IconButton(
            icon: Icon(Icons.assignment),
            color: pageRoute.contains('commitment')
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.commitmentPageRoute,
              (context) => false,
            ),
          ),
        ],
      ),
    );
  }
}
