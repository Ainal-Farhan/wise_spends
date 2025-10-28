import 'package:flutter/material.dart';

class ThLoggedInMainTemplate extends StatelessWidget {
  final Widget screen;
  final String pageRoute;
  final dynamic bloc;
  final List<FloatingActionButton> floatingActionButtons;
  final bool showBottomNavBar;

  const ThLoggedInMainTemplate({
    super.key,
    required this.screen,
    required this.pageRoute,
    required this.bloc,
    this.floatingActionButtons = const <FloatingActionButton>[],
    this.showBottomNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: screen,
      floatingActionButton: floatingActionButtons.isNotEmpty
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: floatingActionButtons,
            )
          : null,
      bottomNavigationBar: showBottomNavBar
          ? Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.3),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.account_balance_wallet),
                    label: 'Wallet',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.assignment),
                    label: 'Commitments',
                  ),
                ],
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
              ),
            )
          : null,
    );
  }
}
