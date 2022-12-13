import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/bottom_navigation_bar/logged_in_bottom_navigation_bar.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class HomeLoggedInPage extends StatefulWidget {
  const HomeLoggedInPage({Key? key}) : super(key: key);

  static const String routeName = router.homeLoggedInPageRoute;

  @override
  _HomeLoggedInPageState createState() => _HomeLoggedInPageState();
}

class _HomeLoggedInPageState extends State<HomeLoggedInPage> {
  final _homeLoggedInBloc = HomeLoggedInBloc();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HomeLoggedIn'),
          automaticallyImplyLeading: false,
        ),
        body: HomeLoggedInScreen(homeLoggedInBloc: _homeLoggedInBloc),
        bottomNavigationBar: const LoggedInBottomNavigationBar(
          pageRoute: router.homeLoggedInPageRoute,
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
