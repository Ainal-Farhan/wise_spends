import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_bloc.dart';
import 'package:wise_spends/bloc/edit_savings/edit_savings_page.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/login/index.dart';
import 'package:wise_spends/bloc/login/state/un_login_state.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/add_money_storage/add_money_storage_page.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/edit_money_storage/edit_money_storage_page.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_bloc.dart';
import 'package:wise_spends/bloc/money_storage/view_list_money_storage/view_list_money_storage_page.dart';
import 'package:wise_spends/bloc/savings/index.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/locator/impl/manager_locator.dart';
import 'package:wise_spends/locator/impl/repository_locator.dart';
import 'package:wise_spends/locator/impl/service_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerSingleton();

  // Do any requests before start the app
  await () async {
    await SingletonUtil.getSingleton<IManagerLocator>()
        .getStartupManager()
        .onRunApp("Ainal");
  }();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<LoginBloc>(
          create: (context) => LoginBloc(const UnLoginState(version: 0)),
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
        BlocProvider<EditSavingsBloc>(
          create: (context) => EditSavingsBloc(),
          child: BlocBuilder<EditSavingsBloc, IState<dynamic>>(
            builder: (context, state) => const EditSavingsPage(savingId: ''),
          ),
        ),
        BlocProvider<AddMoneyStorageBloc>(
          create: (context) => AddMoneyStorageBloc(),
          child: BlocBuilder<AddMoneyStorageBloc, IState<dynamic>>(
            builder: (context, state) => const AddMoneyStoragePage(),
          ),
        ),
        BlocProvider<EditMoneyStorageBloc>(
          create: (context) => EditMoneyStorageBloc(),
          child: BlocBuilder<EditMoneyStorageBloc, IState<dynamic>>(
            builder: (context, state) => const EditMoneyStoragePage(
              selectedMoneyStorageId: '',
            ),
          ),
        ),
        BlocProvider<ViewListMoneyStorageBloc>(
          create: (context) => ViewListMoneyStorageBloc(),
          child: BlocBuilder<ViewListMoneyStorageBloc, IState<dynamic>>(
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
        primaryColor: IThemeManager().colorTheme.backgroundBlue,
      );
}

void _registerSingleton() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());

  SingletonUtil.getSingleton<IRepositoryLocator>().registerLocator();
  SingletonUtil.getSingleton<IServiceLocator>().registerLocator();
  SingletonUtil.getSingleton<IManagerLocator>().registerLocator();
}
