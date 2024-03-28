import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/events/add_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/add_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/state/impl/un_add_money_storage_state.dart';

class AddMoneyStorageBloc
    extends Bloc<AddMoneyStorageEvent, AddMoneyStorageState> {
  static final AddMoneyStorageBloc _addMoneyStorage =
      AddMoneyStorageBloc._internal();
  factory AddMoneyStorageBloc() {
    return _addMoneyStorage;
  }

  AddMoneyStorageBloc._internal()
      : super(const UnAddMoneyStorageState(version: 0)) {
    on<AddMoneyStorageEvent>((event, emit) {
      return emit.forEach<AddMoneyStorageState>(
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
