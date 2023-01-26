import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/edit_savings_page.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/edit_savings/state/edit_savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/home_logged_in/state/home_logged_in_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/login/state/impl/un_login_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/savings/state/savings_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/state/transaction_state.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_bloc.dart';
import 'package:wise_spends/com/ainal/wise/spends/bloc/transaction/transaction_page.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/router/app_router.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/i_theme_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Do any requests before start the app
  await () async {
    await IStartupManager().onRunApp("Ainal");
  }();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<HomeLoggedInBloc>(
          create: (context) => HomeLoggedInBloc(),
          child: BlocBuilder<HomeLoggedInBloc, HomeLoggedInState>(
            builder: (context, state) => const HomeLoggedInPage(),
          ),
        ),
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(const UnLoginState()),
          child: BlocBuilder<LoginBloc, LoginState>(
            builder: (context, state) => const LoginPage(),
          ),
        ),
        BlocProvider<SavingsBloc>(
          create: (context) => SavingsBloc(),
          child: BlocBuilder<SavingsBloc, SavingsState>(
            builder: (context, state) => const SavingsPage(),
          ),
        ),
        BlocProvider<EditSavingsBloc>(
          create: (context) => EditSavingsBloc(),
          child: BlocBuilder<EditSavingsBloc, EditSavingsState>(
            builder: (context, state) => const EditSavingsPage(savingId: ''),
          ),
        ),
        BlocProvider<TransactionBloc>(
          create: (context) => TransactionBloc(),
          child: BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) => const TransactionPage(),
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
      theme: theme,
      initialRoute: AppRouter.savingsPageRoute,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData get theme => ThemeData.light().copyWith(
        brightness: Brightness.light,
        primaryColor: IThemeManager().colorTheme.backgroundBlue,
      );
}
