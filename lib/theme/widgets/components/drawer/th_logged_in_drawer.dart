import 'package:flutter/material.dart';
import 'package:wise_spends/resource/ui/snack_bar/message.dart';
import 'package:wise_spends/router/app_router.dart';

class ThLoggedInDrawer extends StatelessWidget {
  final String userName;
  final String pageRoute;

  const ThLoggedInDrawer({
    super.key,
    this.userName = 'User',
    required this.pageRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Wise Spends',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.savingsPageRoute,
              (context) => false,
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRouter.settingsPageRoute,
              (context) => false,
            ),
          ),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () {
              showSnackBarMessage(context, "Not Implemented yet");
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
