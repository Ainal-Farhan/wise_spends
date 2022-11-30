import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/event/impl/load_transaction_event.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({
    required TransactionBloc transactionBloc,
    Key? key,
  })  : _transactionBloc = transactionBloc,
        super(key: key);

  final TransactionBloc _transactionBloc;

  @override
  TransactionScreenState createState() {
    return TransactionScreenState();
  }
}

class TransactionScreenState extends State<TransactionScreen> {
  TransactionScreenState();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
        bloc: widget._transactionBloc,
        builder: (
          BuildContext context,
          TransactionState currentState,
        ) =>
            currentState.build(context, _load));
  }

  void _load([bool isError = false]) {
    widget._transactionBloc.add(LoadTransactionEvent(isError));
  }
}
