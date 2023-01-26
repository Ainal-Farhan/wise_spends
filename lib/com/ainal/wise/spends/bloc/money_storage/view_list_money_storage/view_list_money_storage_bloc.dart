import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/events/view_list_money_storage_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/impl/un_view_list_money_storage_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/money_storage/view_list_money_storage/state/view_list_money_storage_state.dart';

class ViewListMoneyStorageBloc
    extends Bloc<ViewListMoneyStorageEvent, ViewListMoneyStorageState> {
  static final ViewListMoneyStorageBloc _viewListMoneyStorage =
      ViewListMoneyStorageBloc._internal();
  factory ViewListMoneyStorageBloc() {
    return _viewListMoneyStorage;
  }

  ViewListMoneyStorageBloc._internal()
      : super(const UnViewListMoneyStorageState(version: 0)) {
    on<ViewListMoneyStorageEvent>((event, emit) {
      return emit.forEach<ViewListMoneyStorageState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'EditSavingsBloc', error: error, stackTrace: stackTrace);
          return const UnViewListMoneyStorageState(version: 0);
        },
      );
    });
  }
}
