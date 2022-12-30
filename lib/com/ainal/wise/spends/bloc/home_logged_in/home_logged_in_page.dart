import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/main_template/logged_in_main_template.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class HomeLoggedInPage extends StatefulWidget {
  const HomeLoggedInPage({Key? key}) : super(key: key);

  static const String routeName = router.homeLoggedInPageRoute;

  @override
  State<HomeLoggedInPage> createState() => _HomeLoggedInPageState();
}

class _HomeLoggedInPageState extends State<HomeLoggedInPage> {
  final _homeLoggedInBloc = HomeLoggedInBloc();

  @override
  Widget build(BuildContext context) {
    return LoggedInMainTemplate(
      screen: HomeLoggedInScreen(homeLoggedInBloc: _homeLoggedInBloc),
      pageRoute: router.homeLoggedInPageRoute,
      bloc: _homeLoggedInBloc,
    );
  }
}
