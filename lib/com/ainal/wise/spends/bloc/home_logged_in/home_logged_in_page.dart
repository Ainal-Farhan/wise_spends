import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

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
    return IThLoggedInMainTemplate(
      screen: HomeLoggedInScreen(homeLoggedInBloc: _homeLoggedInBloc),
      pageRoute: router.homeLoggedInPageRoute,
      bloc: _homeLoggedInBloc,
    );
  }
}
