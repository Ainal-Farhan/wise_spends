import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/un_edit_money_storage_state.dart';

class EditMoneyStorageBloc
    extends Bloc<IEvent<EditMoneyStorageBloc>, IState<dynamic>> {
  static final EditMoneyStorageBloc _editMoneyStorage =
      EditMoneyStorageBloc._internal();
  factory EditMoneyStorageBloc() {
    return _editMoneyStorage;
  }

  EditMoneyStorageBloc._internal()
      : super(const UnEditMoneyStorageState(version: 0)) {
    on<IEvent<EditMoneyStorageBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'EditMoneyStorageBloc',
              error: error,
              stackTrace: stackTrace);
          return const UnEditMoneyStorageState(version: 0);
        },
      );
    });
  }
}
