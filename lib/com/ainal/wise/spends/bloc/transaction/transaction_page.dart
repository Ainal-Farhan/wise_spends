import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_screen.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as router;
import 'package:wise_spends/com/ainal/wise/spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class TransactionPage extends StatefulWidget {
  static const String routeName = router.transactionPageRoute;

  const TransactionPage({Key? key}) : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _transactionBloc = TransactionBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      screen: TransactionScreen(transactionBloc: _transactionBloc),
      pageRoute: router.transactionPageRoute,
      bloc: _transactionBloc,
    );
  }
}
