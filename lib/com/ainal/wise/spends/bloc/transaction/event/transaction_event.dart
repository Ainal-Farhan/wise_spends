import 'dart:async';

import 'package:meta/meta.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_repository.dart';

@immutable
abstract class TransactionEvent {
  Stream<TransactionState> applyAsync(
      {TransactionState currentState, TransactionBloc bloc});
  final TransactionRepository _transactionRepository = TransactionRepository();

  TransactionRepository get transactionRepository => _transactionRepository;
}
