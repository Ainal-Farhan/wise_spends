import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as route;

class LoggedInBottomNavigationBar extends StatelessWidget {
  static const Map<String, int> _indexBasedOnPageRoute = {
    route.Router.homeLoggedInPageRoute: 0,
    route.Router.savingsPageRoute: 1,
    route.Router.transactionPageRoute: 2,
  };

  const LoggedInBottomNavigationBar({
    Key? key,
    required this.pageRoute,
  }) : super(key: key);

  final String pageRoute;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.savings),
          label: 'Savings',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.attach_money),
          label: 'Transaction',
        ),
      ],
      currentIndex: _indexBasedOnPageRoute[pageRoute] ?? 0,
      onTap: (int index) {
        int selectedIndex = _indexBasedOnPageRoute[pageRoute] ?? 0;
        if (index != selectedIndex) {
          Navigator.pushReplacementNamed(
            context,
            _indexBasedOnPageRoute.keys.elementAt(index),
          );
        }
      },
    );
  }
}