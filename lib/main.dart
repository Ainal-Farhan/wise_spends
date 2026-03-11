import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/constants/app_routes.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/di/impl/manager_locator.dart';
import 'package:wise_spends/core/di/impl/repository_locator.dart';
import 'package:wise_spends/core/di/impl/service_locator.dart';
import 'package:wise_spends/core/error_handling/run_guard.dart';
import 'package:wise_spends/core/logger/logger.dart';
import 'package:wise_spends/core/utils/hidden_gesture_detector.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart'
    as data_transaction;
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/presentation/services/widget_background_service.dart';
import 'package:wise_spends/presentation/services/widget_platform_channel.dart';
import 'package:wise_spends/presentation/services/widget_service.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register singletons
  _registerSingletons();

  // Initialize widget service
  await WidgetService.initialize();
  WidgetService.registerInteractivityCallback();

  WidgetPlatformChannel.initialize();

  // Initialize background updates
  WidgetBackgroundService.initialize();

  // Initialize startup manager
  await SingletonUtil.getSingleton<IManagerLocator>()
      ?.getStartupManager()
      .onRunApp(null);

  runApp(const WiseSpendsApp());
}

class WiseSpendsApp extends StatelessWidget {
  const WiseSpendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize widget platform channel after context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Start periodic background updates for widget
      WidgetBackgroundService.startPeriodicUpdates();
    });

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
          navigatorKey: AppRouter.navigatorKey,
          builder: (context, child) {
            return RunGuard(
              navigatorKey: AppRouter.navigatorKey,
              child: HiddenGestureDetector(
                onTriggered: () {
                  WiseLogger().info('Hidden menu accessed', tag: 'Main');
                  AppRouter.navigatorKey.currentState?.pushNamed(
                    AppRoutes.hiddenUtilityMenu,
                  );
                },
                child: child!,
              ),
            );
          },
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
