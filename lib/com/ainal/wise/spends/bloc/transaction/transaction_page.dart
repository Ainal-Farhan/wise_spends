import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_screen.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/main_template/logged_in_main_template.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;

class TransactionPage extends StatefulWidget {
  static const String routeName = router.transactionPageRoute;

  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _transactionBloc = TransactionBloc();

  @override
  Widget build(BuildContext context) {
    return LoggedInMainTemplate(
      screen: TransactionScreen(transactionBloc: _transactionBloc),
      pageRoute: router.transactionPageRoute,
      bloc: _transactionBloc,
    );
  }
}
