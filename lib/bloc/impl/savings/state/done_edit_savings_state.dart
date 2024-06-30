import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/savings/event/load_list_savings_event.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';

class DoneEditSavingsState extends IState<DoneEditSavingsState> {
  final String nextScreenRoute;
  final String message;

  const DoneEditSavingsState({
    super.version = 0,
    required this.nextScreenRoute,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * .45),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => BlocProvider.of<SavingsBloc>(context)
                .add(LoadListSavingsEvent()),
          ),
        ],
      ),
    );
  }

  @override
  DoneEditSavingsState getNewVersion() => DoneEditSavingsState(
        version: version + 1,
        nextScreenRoute: nextScreenRoute,
        message: message,
      );

  @override
  DoneEditSavingsState getStateCopy() => DoneEditSavingsState(
        version: version,
        nextScreenRoute: nextScreenRoute,
        message: message,
      );

  @override
  List<Object> get props => [];

  @override
  bool? get stringify => null;
}
