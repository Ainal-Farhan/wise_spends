import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/events/in_load_add_money_storage_event.dart';

class AddMoneyStorageScreen extends StatefulWidget {
  const AddMoneyStorageScreen({
    required AddMoneyStorageBloc addMoneyStorageBloc,
    super.key,
  }) : _addMoneyStorageBloc = addMoneyStorageBloc;

  final AddMoneyStorageBloc _addMoneyStorageBloc;

  @override
  State<AddMoneyStorageScreen> createState() => _AddMoneyStorageScreenState();
}

class _AddMoneyStorageScreenState extends State<AddMoneyStorageScreen> {
  @override
  void initState() {
    super.initState();
    widget._addMoneyStorageBloc.add(InLoadAddMoneyStorageEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddMoneyStorageBloc, IState<dynamic>>(
        bloc: widget._addMoneyStorageBloc,
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) {
          try {
            return currentState.build(context);
          } catch (_) {
            return currentState as Widget;
          }
        });
  }
}
