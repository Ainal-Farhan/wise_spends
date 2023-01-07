import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

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
    return IThLoggedInMainTemplate(
      pageRoute: router.savingsPageRoute,
      screen: SavingsScreen(savingsBloc: _savingsBloc),
      bloc: _savingsBloc,
    );
  }
}
