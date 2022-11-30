import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_transaction_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/impl/transaction_manager.dart';

@immutable
abstract class TransactionEvent {
  Stream<TransactionState> applyAsync(
      {TransactionState currentState, TransactionBloc bloc});
  final ITransactionManager _transactionManager = TransactionManager();

  ITransactionManager get transactionManager => _transactionManager;
}
