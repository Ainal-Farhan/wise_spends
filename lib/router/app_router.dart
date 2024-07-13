import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_page.dart';
import 'package:wise_spends/bloc/impl/login/login_page.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_page.dart';
import 'package:wise_spends/bloc/impl/savings/savings_page.dart';

abstract class AppRouter {
  static const String rootRoute = "/";
  static const String loginPageRoute = "/loginPage";
  static const String homeLoggedInPageRoute = "/homeLoggedInPage";
  static const String savingsPageRoute = "/savingsPage";
  static const String commitmentPageRoute = "/commitmentPage";
  static const String transactionPageRoute = "/transactionPage";
  static const String viewListMoneyStoragePageRoute =
      "/viewListMoneyStoragePageRoute";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case savingsPageRoute:
        return MaterialPageRoute(builder: (_) => const SavingsPage());
      case viewListMoneyStoragePageRoute:
        return MaterialPageRoute(builder: (_) => const MoneyStoragePage());
      case commitmentPageRoute:
        return MaterialPageRoute(builder: (_) => const CommitmentPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
