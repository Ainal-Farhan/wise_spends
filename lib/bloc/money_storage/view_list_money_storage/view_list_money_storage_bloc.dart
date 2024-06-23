import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_event.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/state/un_view_list_money_storage_state.dart';

class ViewListMoneyStorageBloc
    extends Bloc<IEvent<ViewListMoneyStorageBloc>, IState<dynamic>> {
  static final ViewListMoneyStorageBloc _viewListMoneyStorage =
      ViewListMoneyStorageBloc._internal();
  factory ViewListMoneyStorageBloc() {
    return _viewListMoneyStorage;
  }

  ViewListMoneyStorageBloc._internal()
      : super(const UnViewListMoneyStorageState(version: 0)) {
    on<IEvent<ViewListMoneyStorageBloc>>((event, emit) {
      return emit.forEach<IState<dynamic>>(
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
