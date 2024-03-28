import 'dart:async';
import 'dart:developer' as developer;

import 'package:bloc/bloc.dart';
import 'package:wise_spends/bloc/transaction/event/transaction_event.dart';
import 'package:wise_spends/bloc/transaction/state/impl/error_transaction_state.dart';
import 'package:wise_spends/bloc/transaction/state/impl/un_transaction_state.dart';
import 'package:wise_spends/bloc/transaction/state/transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  // todo: check singleton for logic in project
  // use GetIt for DI in projct
  static final TransactionBloc _transactionBlocSingleton =
      TransactionBloc._internal();
  factory TransactionBloc() {
    return _transactionBlocSingleton;
  }

  TransactionBloc._internal() : super(const UnTransactionState(0)) {
    on<TransactionEvent>((event, emit) {
      return emit.forEach<TransactionState>(
        event.applyAsync(currentState: state, bloc: this),
        onData: (state) => state,
        onError: (error, stackTrace) {
          developer.log('$error',
              name: 'TransactionBloc', error: error, stackTrace: stackTrace);
          return ErrorTransactionState(0, error.toString());
        },
      );
    });
  }

  @override
  Future<void> close() async {
    // dispose objects
    await super.close();
  }
}
