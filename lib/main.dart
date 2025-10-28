import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wise Spends',
      theme: _getThemeData(),
      darkTheme: _getDarkThemeData(),
      themeMode: _getThemeMode(),
      initialRoute: AppRouter.savingsPageRoute,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData _getThemeData() {
    final themeManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getThemeManager();
    return ThemeData.light().copyWith(
      brightness: Brightness.light,
      primaryColor: themeManager.colorTheme.backgroundBlue,
      scaffoldBackgroundColor: Colors.grey[50],
      appBarTheme: AppBarTheme(
        backgroundColor: themeManager.colorTheme.backgroundBlue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeManager.colorTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeData _getDarkThemeData() {
    final themeManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getThemeManager();
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: themeManager.colorTheme.backgroundBlue,
      scaffoldBackgroundColor: themeManager.colorTheme.complexDrawerCanvasColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeManager.colorTheme.complexDrawerBlueGrey,
        foregroundColor: themeManager.colorTheme.complexDrawerBlack,
        titleTextStyle: TextStyle(
          color: themeManager.colorTheme.complexDrawerBlack,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeManager.colorTheme.primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  ThemeMode _getThemeMode() {
    final currentTheme = SingletonUtil.getSingleton<IManagerLocator>()!
        .getConfigurationManager()
        .getTheme();

    return currentTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }
}

void _registerSingleton() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());
}
