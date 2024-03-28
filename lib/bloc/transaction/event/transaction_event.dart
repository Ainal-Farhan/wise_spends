import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/manager/i_transaction_manager.dart';

@immutable
abstract class TransactionEvent {
  Stream<TransactionState> applyAsync(
      {TransactionState currentState, TransactionBloc bloc});
  final ITransactionManager _transactionManager = ITransactionManager();

  ITransactionManager get transactionManager => _transactionManager;
}
