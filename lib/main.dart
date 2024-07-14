import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/commitment/commitment_bloc.dart';
import 'package:wise_spends/bloc/impl/commitment_task/commitment_task_bloc.dart';
import 'package:wise_spends/bloc/impl/login/login_bloc.dart';
import 'package:wise_spends/bloc/impl/money_storage/money_storage_bloc.dart';
import 'package:wise_spends/bloc/impl/savings/savings_bloc.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/locator/impl/manager_locator.dart';
import 'package:wise_spends/locator/impl/repository_locator.dart';
import 'package:wise_spends/locator/impl/service_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/utils/singleton_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerSingleton();

  // Do any requests before start the app
  await () async {
    await SingletonUtil.getSingleton<IManagerLocator>()
        ?.getStartupManager()
        .onRunApp(null);
  }();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
          child: BlocBuilder<LoginBloc, IState<dynamic>>(
            builder: (context, state) => state.build(context),
          ),
        ),
        BlocProvider<SavingsBloc>(
          create: (context) => SavingsBloc(),
          child: BlocBuilder<SavingsBloc, IState<dynamic>>(
            builder: (context, state) => state.build(context),
          ),
        ),
        BlocProvider<MoneyStorageBloc>(
          create: (context) => MoneyStorageBloc(),
          child: BlocBuilder<MoneyStorageBloc, IState<dynamic>>(
            builder: (context, state) => state.build(context),
          ),
        ),
        BlocProvider<CommitmentBloc>(
          create: (context) => CommitmentBloc(),
          child: BlocBuilder<CommitmentBloc, IState<dynamic>>(
            builder: (context, state) => state.build(context),
          ),
        ),
        BlocProvider<CommitmentTaskBloc>(
          create: (context) => CommitmentTaskBloc(),
          child: BlocBuilder<CommitmentTaskBloc, IState<dynamic>>(
            builder: (context, state) => state.build(context),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
        primaryColor: SingletonUtil.getSingleton<IManagerLocator>()!
            .getThemeManager()
            .colorTheme
            .backgroundBlue,
      );
}

void _registerSingleton() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());
}
