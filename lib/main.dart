import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage_page.dart';
import 'package:wise_spends/bloc/savings/index.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/locator/impl/manager_locator.dart';
import 'package:wise_spends/locator/impl/repository_locator.dart';
import 'package:wise_spends/locator/impl/service_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/util/singleton_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerSingleton();

  // Do any requests before start the app
  await () async {
    await SingletonUtil.getSingleton<IManagerLocator>()
        ?.getStartupManager()
        .onRunApp("Ainal");
  }();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(),
          child: BlocBuilder<LoginBloc, IState<dynamic>>(
            builder: (context, state) => const LoginPage(),
          ),
        ),
        BlocProvider<SavingsBloc>(
          create: (context) => SavingsBloc(),
          child: BlocBuilder<SavingsBloc, IState<dynamic>>(
            builder: (context, state) => const SavingsPage(),
          ),
        ),
        BlocProvider<MoneyStorageBloc>(
          create: (context) => MoneyStorageBloc(),
          child: BlocBuilder<MoneyStorageBloc, IState<dynamic>>(
            builder: (context, state) => const ViewListMoneyStoragePage(),
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
