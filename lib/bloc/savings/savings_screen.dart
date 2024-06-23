import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/savings/savings_bloc.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({
    required SavingsBloc savingsBloc,
    super.key,
  });

  @override
  SavingsScreenState createState() {
    return SavingsScreenState();
  }
}

class SavingsScreenState extends State<SavingsScreen> {
  SavingsScreenState();

  @override
  void initState() {
    super.initState();
    SavingsBloc().add(LoadListSavingsEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsBloc, IState<dynamic>>(
        bloc: SavingsBloc(),
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) =>
            currentState.build(context));
  }
}
