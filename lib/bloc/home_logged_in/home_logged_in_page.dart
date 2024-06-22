import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class HomeLoggedInPage extends StatefulWidget {
  const HomeLoggedInPage({super.key});

  static const String routeName = AppRouter.homeLoggedInPageRoute;

  @override
  State<HomeLoggedInPage> createState() => _HomeLoggedInPageState();
}

class _HomeLoggedInPageState extends State<HomeLoggedInPage> {
  final _homeLoggedInBloc = HomeLoggedInBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      screen: HomeLoggedInScreen(homeLoggedInBloc: _homeLoggedInBloc),
      pageRoute: HomeLoggedInPage.routeName,
      bloc: _homeLoggedInBloc,
    );
  }
}
