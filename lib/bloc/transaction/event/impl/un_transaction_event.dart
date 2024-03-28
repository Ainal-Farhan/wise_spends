import 'package:wise_spends/bloc/transaction/event/transaction_event.dart';
import 'package:wise_spends/bloc/transaction/state/impl/un_transaction_state.dart';
import 'package:wise_spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/bloc/transaction/transaction_bloc.dart';

class UnTransactionEvent extends TransactionEvent {
  @override
  Stream<TransactionState> applyAsync(
      {TransactionState? currentState, TransactionBloc? bloc}) async* {
    yield const UnTransactionState(0);
  }
}
