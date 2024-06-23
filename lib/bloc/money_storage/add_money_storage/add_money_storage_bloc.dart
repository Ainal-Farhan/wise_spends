import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/un_add_money_storage_state.dart';

class AddMoneyStorageBloc
    extends Bloc<IEvent<AddMoneyStorageBloc>, IState<dynamic>> {
  static final AddMoneyStorageBloc _addMoneyStorage =
      AddMoneyStorageBloc._internal();
  factory AddMoneyStorageBloc() {
    return _addMoneyStorage;
  }

  AddMoneyStorageBloc._internal()
      : super(const UnAddMoneyStorageState(version: 0)) {
    on<IEvent<AddMoneyStorageBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'AddMoneyStorageBloc',
              error: error,
              stackTrace: stackTrace);
          return const UnAddMoneyStorageState(version: 0);
        },
      );
    });
  }
}
