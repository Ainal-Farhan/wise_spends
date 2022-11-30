import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/home_logged_in_page.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_page.dart';

abstract class Router {
  static const String loginPageRoute = "/loginPage";
  static const String homeLoggedInPageRoute = "/homeLoggedInPage";
  static const String savingsPageRoute = "/savingsPage";
  static const String transactionPageRoute = "/transactionPage";

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case homeLoggedInPageRoute:
        return MaterialPageRoute(builder: (_) => const HomeLoggedInPage());
      case savingsPageRoute:
        return MaterialPageRoute(builder: (_) => const SavingsPage());
      case transactionPageRoute:
        return MaterialPageRoute(builder: (_) => const TransactionPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
