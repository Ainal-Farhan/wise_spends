import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/savings/index.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class SavingsPage extends StatefulWidget {
  static const String routeName = AppRouter.savingsPageRoute;

  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  @override
  Widget build(BuildContext context) {
    final savingsBloc = BlocProvider.of<SavingsBloc>(context);
    return IThLoggedInMainTemplate(
      pageRoute: SavingsPage.routeName,
      screen: SavingsScreen(savingsBloc: savingsBloc),
      bloc: savingsBloc,
    );
  }
}
