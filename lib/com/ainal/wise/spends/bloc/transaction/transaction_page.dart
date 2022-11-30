import 'package:flutter/material.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_screen.dart';
import 'package:wise_spends/com/ainal/wise/spends/resource/widget/bottom_navigation_bar/logged_in_bottom_navigation_bar.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as route;

class TransactionPage extends StatefulWidget {
  static const String routeName = route.Router.transactionPageRoute;

  const TransactionPage({Key? key}) : super(key: key);

  @override
  _TransactionPageState createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _transactionBloc = TransactionBloc();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Transaction'),
          automaticallyImplyLeading: false,
        ),
        body: TransactionScreen(transactionBloc: _transactionBloc),
        bottomNavigationBar: const LoggedInBottomNavigationBar(
          pageRoute: route.Router.transactionPageRoute,
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
