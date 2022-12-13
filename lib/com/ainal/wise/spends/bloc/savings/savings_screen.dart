import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/impl/load_list_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/event/savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';

class SavingsScreen extends StatefulWidget {
  const SavingsScreen({
    required SavingsBloc savingsBloc,
    Key? key,
  })  : _savingsBloc = savingsBloc,
        super(key: key);

  final SavingsBloc _savingsBloc;

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
    _load(savingsEvent: LoadListSavingsEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavingsBloc, SavingsState>(
        bloc: widget._savingsBloc,
        builder: (
          BuildContext context,
          SavingsState currentState,
        ) =>
            currentState.build(context, _load));
  }

  void _load({SavingsEvent? savingsEvent}) {
    if (savingsEvent != null) widget._savingsBloc.add(savingsEvent);
  }
}
