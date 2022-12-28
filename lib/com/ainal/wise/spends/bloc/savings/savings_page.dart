import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/bottom_navigation_bar/logged_in_bottom_navigation_bar.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class SavingsPage extends StatefulWidget {
  static const String routeName = router.savingsPageRoute;

  const SavingsPage({Key? key}) : super(key: key);

  @override
  _SavingsPageState createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _savingsBloc = SavingsBloc();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Savings'),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: SavingsScreen(savingsBloc: _savingsBloc),
        ),
        bottomNavigationBar: const LoggedInBottomNavigationBar(
          pageRoute: router.savingsPageRoute,
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
