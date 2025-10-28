import 'package:flutter/material.dart';

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
            color: pageRoute.contains('savings') ? Theme.of(context).colorScheme.primary : Colors.grey,
            onPressed: () => Navigator.pushNamed(context, '/savings'),
          ),
          IconButton(
            icon: Icon(Icons.account_balance_wallet),
            color: pageRoute.contains('money_storage') ? Theme.of(context).colorScheme.primary : Colors.grey,
            onPressed: () => Navigator.pushNamed(context, '/money_storage'),
          ),
          IconButton(
            icon: Icon(Icons.assignment),
            color: pageRoute.contains('commitment') ? Theme.of(context).colorScheme.primary : Colors.grey,
            onPressed: () => Navigator.pushNamed(context, '/commitment'),
          ),
          IconButton(
            icon: Icon(Icons.check_circle),
            color: pageRoute.contains('commitment_task') ? Theme.of(context).colorScheme.primary : Colors.grey,
            onPressed: () => Navigator.pushNamed(context, '/commitment_task'),
          ),
        ],
      ),
    );
  }
}