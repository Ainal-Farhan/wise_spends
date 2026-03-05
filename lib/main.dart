import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/di/impl/manager_locator.dart';
import 'package:wise_spends/core/di/impl/repository_locator.dart';
import 'package:wise_spends/core/di/impl/service_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart'
    as data_transaction;
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerSingletons();

  // Run any startup managers
  await SingletonUtil.getSingleton<IManagerLocator>()
      ?.getStartupManager()
      .onRunApp(null);

  runApp(const WiseSpendsApp());
}

class WiseSpendsApp extends StatelessWidget {
  const WiseSpendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<data_transaction.ITransactionRepository>.value(
          value: SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getTransactionRepository(),
        ),
        RepositoryProvider.value(
          value: SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getBudgetRepository(),
        ),
        RepositoryProvider.value(
          value: SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getCategoryRepository(),
        ),
        RepositoryProvider.value(
          value: SingletonUtil.getSingleton<IRepositoryLocator>()!
              .getSavingRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => ActionButtonBloc())],
        child: MaterialApp(
          title: 'WiseSpends',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.light,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRouter.generateRoute,
        ),
      ),
    );
  }
}

void _registerSingletons() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());
}
