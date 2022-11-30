import 'dart:developer' as developer;

import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/event/transaction_event.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/impl/error_transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/impl/in_transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/impl/un_transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';

class LoadTransactionEvent extends TransactionEvent {
  final bool isError;
  @override
  String toString() => 'LoadTransactionEvent';

  LoadTransactionEvent(this.isError);

  @override
  Stream<TransactionState> applyAsync(
      {TransactionState? currentState, TransactionBloc? bloc}) async* {
    try {
      yield const UnTransactionState(0);
      await Future.delayed(const Duration(seconds: 1));
      transactionManager.test(isError);
      yield const InTransactionState(0, 'Hello world');
    } catch (_, stackTrace) {
      developer.log('$_',
          name: 'LoadTransactionEvent', error: _, stackTrace: stackTrace);
      yield ErrorTransactionState(0, _.toString());
    }
  }
}
