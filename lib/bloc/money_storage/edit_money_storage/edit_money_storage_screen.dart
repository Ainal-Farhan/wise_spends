import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/events/in_load_edit_money_storage_event.dart';

class EditMoneyStorageScreen extends StatefulWidget {
  const EditMoneyStorageScreen({
    required EditMoneyStorageBloc editMoneyStorageBloc,
    required this.selectedMoneyStorageId,
    super.key,
  })  : _editMoneyStorageBloc = editMoneyStorageBloc;

  final String selectedMoneyStorageId;
  final EditMoneyStorageBloc _editMoneyStorageBloc;

  @override
  State<EditMoneyStorageScreen> createState() => _EditMoneyStorageScreenState();
}

class _EditMoneyStorageScreenState extends State<EditMoneyStorageScreen> {
  @override
  void initState() {
    super.initState();
    EditMoneyStorageBloc()
        .add(InLoadEditMoneyStorageEvent(widget.selectedMoneyStorageId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditMoneyStorageBloc, IState<dynamic>>(
        bloc: widget._editMoneyStorageBloc,
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
