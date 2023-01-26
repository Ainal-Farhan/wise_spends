import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/events/impl/in_load_add_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';

class AddMoneyStorageScreen extends StatefulWidget {
  const AddMoneyStorageScreen({
    required AddMoneyStorageBloc addMoneyStorageBloc,
    Key? key,
  })  : _addMoneyStorageBloc = addMoneyStorageBloc,
        super(key: key);

  final AddMoneyStorageBloc _addMoneyStorageBloc;

  @override
  State<AddMoneyStorageScreen> createState() => _AddMoneyStorageScreenState();
}

class _AddMoneyStorageScreenState extends State<AddMoneyStorageScreen> {
  @override
  void initState() {
    super.initState();
    AddMoneyStorageBloc().add(InLoadAddMoneyStorageEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddMoneyStorageBloc, AddMoneyStorageState>(
        bloc: widget._addMoneyStorageBloc,
        builder: (
          BuildContext context,
          AddMoneyStorageState currentState,
        ) {
          try {
            return currentState.build(context);
          } catch (_) {
            return currentState as Widget;
          }
        });
  }
}
