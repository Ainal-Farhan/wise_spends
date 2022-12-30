import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widgets/main_template/logged_in_main_template.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class SavingsPage extends StatefulWidget {
  static const String routeName = router.savingsPageRoute;

  const SavingsPage({Key? key}) : super(key: key);

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _savingsBloc = SavingsBloc();

  @override
  Widget build(BuildContext context) {
    return LoggedInMainTemplate(
      pageRoute: router.savingsPageRoute,
      screen: SavingsScreen(savingsBloc: _savingsBloc),
      bloc: _savingsBloc,
    );
  }
}
