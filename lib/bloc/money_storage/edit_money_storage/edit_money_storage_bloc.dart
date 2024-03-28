import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/events/edit_money_storage_event.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/edit_money_storage_state.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/state/impl/un_edit_money_storage_state.dart';

class EditMoneyStorageBloc
    extends Bloc<EditMoneyStorageEvent, EditMoneyStorageState> {
  static final EditMoneyStorageBloc _editMoneyStorage =
      EditMoneyStorageBloc._internal();
  factory EditMoneyStorageBloc() {
    return _editMoneyStorage;
  }

  EditMoneyStorageBloc._internal()
      : super(const UnEditMoneyStorageState(version: 0)) {
    on<EditMoneyStorageEvent>((event, emit) {
      return emit.forEach<EditMoneyStorageState>(
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
