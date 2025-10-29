import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/blocs/commitment/commitment_page.dart';
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
        return getMaterialPageRoute(const LoginPage());
      case rootRoute:
      case homeLoggedInPageRoute:
        return getMaterialPageRoute(const HomePage());
      case savingsPageRoute:
        return getMaterialPageRoute(const SavingsPage());
      case viewListMoneyStoragePageRoute:
        return getMaterialPageRoute(const MoneyStoragePage());
      case commitmentPageRoute:
        return getMaterialPageRoute(const CommitmentPage());
      case commitmentTaskPageRoute:
        return getMaterialPageRoute(const CommitmentTaskPage());
      case settingsPageRoute:
        return getMaterialPageRoute(const SettingsPage());
      case profilePageRoute:
        return getMaterialPageRoute(const ProfilePage());
      default:
        return getMaterialPageRoute(
          Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute getMaterialPageRoute(Widget widget) =>
      MaterialPageRoute(
        builder: (context) {
          BlocProvider.of<ActionButtonBloc>(
            context,
          ).add(OnUpdateActionButtonEvent(context: context));
          return widget;
        },
      );
}
