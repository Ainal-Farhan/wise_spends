import 'package:flutter/material.dart';
import 'package:wise_spends/presentation/blocs/commitment_bloc/commitment_page.dart';
import 'package:wise_spends/presentation/screens/login/ui/login_page.dart';
import 'package:wise_spends/presentation/screens/settings/ui/settings_page.dart';
import 'package:wise_spends/presentation/pages/home/home_page.dart';
import 'package:wise_spends/presentation/pages/money_storage/money_storage_page.dart';
import 'package:wise_spends/presentation/pages/commitment_task/commitment_task_page.dart';
import 'package:wise_spends/presentation/pages/profile/profile_page.dart';
import 'package:wise_spends/presentation/pages/savings/savings_page.dart';

abstract class AppRouter {
  static const String rootRoute = "/";
  static const String loginPageRoute = "/login";
  static const String homeLoggedInPageRoute = "/home";
  static const String savingsPageRoute = "/savings";
  static const String commitmentPageRoute = "/commitment";
  static const String transactionPageRoute = "/transaction";
  static const String commitmentTaskPageRoute = "/commitment_task";
  static const String viewListMoneyStoragePageRoute = "/money_storage";
  static const String settingsPageRoute = "/settings";
  static const String profilePageRoute = "/profile";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case rootRoute:
      case loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case rootRoute:
      case homeLoggedInPageRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case savingsPageRoute:
        return MaterialPageRoute(builder: (_) => const SavingsPage());
      case viewListMoneyStoragePageRoute:
        return MaterialPageRoute(builder: (_) => const MoneyStoragePage());
      case commitmentPageRoute:
        return MaterialPageRoute(builder: (_) => const CommitmentPage());
      case commitmentTaskPageRoute:
        return MaterialPageRoute(builder: (_) => const CommitmentTaskPage());
      case settingsPageRoute:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      case profilePageRoute:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
