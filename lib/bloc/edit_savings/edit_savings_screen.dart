import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/event/load_edit_savings_event.dart';
import 'package:wise_spends/bloc/i_state.dart';

class EditSavingsScreen extends StatefulWidget {
  final String savingId;

  const EditSavingsScreen({
    required EditSavingsBloc editSavingsBloc,
    required this.savingId,
    super.key,
  }) : _editSavingsBloc = editSavingsBloc;

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
    widget._editSavingsBloc.add(LoadEditSavingsEvent(widget.savingId));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditSavingsBloc, IState<dynamic>>(
        bloc: widget._editSavingsBloc,
        builder: (
          BuildContext context,
          IState<dynamic> currentState,
        ) =>
            currentState.build(context));
  }
}
