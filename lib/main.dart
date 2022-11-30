import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_page.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/index.dart' as route;
import 'package:wise_spends/com/ainal/wise/spends/utils/uuid_generator.dart';

void main() {
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeLoggedInBloc>(
          create: (context) => HomeLoggedInBloc(),
          child: BlocBuilder<HomeLoggedInBloc, HomeLoggedInState>(
            builder: (context, state) {
              return const HomeLoggedInPage();
            },
          ),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(const UnLoginState()),
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) {
              return const LoginPage();
            },
          ),
        ),
        BlocProvider<SavingsBloc>(
          create: (context) => SavingsBloc(),
          child: BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, state) {
              return const SavingsPage();
            },
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(),
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              return const TransactionPage();
            },
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wise Spends',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: route.Router.homeLoggedInPageRoute,
      onGenerateRoute: route.Router.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}
