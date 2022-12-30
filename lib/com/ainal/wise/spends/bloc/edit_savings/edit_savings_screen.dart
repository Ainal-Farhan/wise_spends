import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/event/impl/load_edit_savings_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';

class EditSavingsScreen extends StatefulWidget {
  const EditSavingsScreen({
    required EditSavingsBloc editSavingsBloc,
    Key? key,
  })  : _editSavingsBloc = editSavingsBloc,
        super(key: key);

  final EditSavingsBloc _editSavingsBloc;

  @override
  EditSavingsScreenState createState() {
    return EditSavingsScreenState();
  }
}

class EditSavingsScreenState extends State<EditSavingsScreen> {
  EditSavingsScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditSavingsBloc, EditSavingsState>(
        bloc: widget._editSavingsBloc,
        builder: (
          BuildContext context,
          EditSavingsState currentState,
        ) =>
            currentState.build(context));
  }

  void _load([bool isError = false]) {
    widget._editSavingsBloc.add(LoadEditSavingsEvent(isError));
  }
}
