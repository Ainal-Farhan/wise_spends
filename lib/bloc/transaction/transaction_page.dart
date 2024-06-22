import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/bloc/transaction/transaction_screen.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/widgets/components/templates/i_th_logged_in_main_template.dart';

class TransactionPage extends StatefulWidget {
  static const String routeName = AppRouter.transactionPageRoute;

  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _transactionBloc = TransactionBloc();

  @override
  Widget build(BuildContext context) {
    return IThLoggedInMainTemplate(
      screen: TransactionScreen(transactionBloc: _transactionBloc),
      pageRoute: TransactionPage.routeName,
      bloc: _transactionBloc,
    );
  }
}
