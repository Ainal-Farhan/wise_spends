import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_page.dart';
import 'package:wise_spends/bloc/home_logged_in/home_logged_in_page.dart';
import 'package:wise_spends/bloc/login/login_page.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_page.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_page.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_page.dart';
import 'package:wise_spends/bloc/savings/savings_page.dart';
import 'package:wise_spends/bloc/transaction/transaction_page.dart';
import 'package:wise_spends/router/screen_argument.dart';

abstract class AppRouter {
  static const String rootRoute = "/";
  static const String loginPageRoute = "/loginPage";
  static const String homeLoggedInPageRoute = "/homeLoggedInPage";
  static const String savingsPageRoute = "/savingsPage";
  static const String transactionPageRoute = "/transactionPage";
  static const String editSavingsPageRoute = "/editSavingsPageRoute";
  static const String viewListMoneyStoragePageRoute =
      "/viewListMoneyStoragePageRoute";
  static const String addMoneyStoragePageRoute = '/addMoneyStoragePageRoute';
  static const String editMoneyStoragePageRoute = '/editMoneyStoragePageRoute';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    ScreenArgument screenArgument =
        (settings.arguments ?? ScreenArgument({})) as ScreenArgument;

    switch (settings.name) {
      case loginPageRoute:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case homeLoggedInPageRoute:
        return MaterialPageRoute(builder: (_) => const HomeLoggedInPage());
      case savingsPageRoute:
        return MaterialPageRoute(builder: (_) => const SavingsPage());
      case transactionPageRoute:
        return MaterialPageRoute(builder: (_) => const TransactionPage());
      case editSavingsPageRoute:
        return MaterialPageRoute(
            builder: (_) => EditSavingsPage(
                savingId: screenArgument.arguments['savingId']));
      case viewListMoneyStoragePageRoute:
        return MaterialPageRoute(
            builder: (_) => const ViewListMoneyStoragePage());
      case addMoneyStoragePageRoute:
        return MaterialPageRoute(builder: (_) => const AddMoneyStoragePage());
      case editMoneyStoragePageRoute:
        return MaterialPageRoute(
            builder: (_) => EditMoneyStoragePage(
                  selectedMoneyStorageId:
                      screenArgument.arguments['moneyStorageId'] ?? '',
                ));
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
