import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_page.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_page.dart';
import 'package:wise_spends/bloc/impl/login/login_page.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_page.dart';
import 'package:wise_spends/bloc/impl/savings/savings_page.dart';
import 'package:wise_spends/bloc/impl/settings/settings_page.dart';

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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // case rootRoute:
      case loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case rootRoute:
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
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
