import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
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
import 'package:wise_spends/features/settings/presentation/screens/bloc/settings_bloc.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart'
    as feature_transaction;
import 'package:wise_spends/features/widget/presentation/services/widget_background_service.dart';
import 'package:wise_spends/features/widget/presentation/services/widget_platform_channel.dart';
import 'package:wise_spends/features/widget/presentation/services/widget_service.dart';
import 'package:wise_spends/presentation/blocs/action_button/action_button_bloc.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/shared/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _registerSingletons();

  await WidgetService.initialize();
  WidgetService.registerInteractivityCallback();
  WidgetPlatformChannel.initialize();
  WidgetBackgroundService.initialize();

  await SingletonUtil.getSingleton<IManagerLocator>()
      ?.getStartupManager()
      .onRunApp(null);

  runApp(const WiseSpendsApp());
}

class WiseSpendsApp extends StatelessWidget {
  const WiseSpendsApp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      WidgetBackgroundService.startPeriodicUpdates();
    });

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<feature_transaction.ITransactionRepository>.value(
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
        providers: [
          BlocProvider(create: (_) => ActionButtonBloc()),
          // SettingsBloc lives at the root so both AppRoot and any deep
          // descendant can read it via context.read<SettingsBloc>().
          BlocProvider(
            create: (_) => SettingsBloc()..add(const LoadSettingsEvent()),
          ),
        ],
        child: const _AppRoot(),
      ),
    );
  }
}

/// Root widget that wires [SettingsBloc] streams and [LocalizationService]
/// into [MaterialApp].
///
/// ### Why [_rebuildKey]?
/// `.tr` is a static extension that reads [LocalizationService]'s in-memory
/// string map at the moment `build()` runs. After a locale swap, the map is
/// updated but already-rendered widgets still show the old strings — they
/// were built before the change and nothing tells them to rebuild.
///
/// Incrementing `_rebuildKey` and passing it to [KeyedSubtree] forces Flutter
/// to destroy the old [MaterialApp] subtree and mount a fresh one, so every
/// single `.tr` call re-evaluates against the new map. Theme changes do NOT
/// need this — [MaterialApp.themeMode] propagates through InheritedWidget
/// automatically.
class _AppRoot extends StatefulWidget {
  const _AppRoot();

  @override
  State<_AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<_AppRoot> {
  int _rebuildKey = 0;

  @override
  void initState() {
    super.initState();
    // Listen directly on LocalizationService — catches locale changes from
    // ANY caller (SettingsBloc, deep links, tests, etc.).
    LocalizationService().localeChangeStream.listen((_) {
      if (mounted) setState(() => _rebuildKey++);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsBloc = context.read<SettingsBloc>();

    final initialTheme = settingsBloc.state is SettingsLoaded
        ? (settingsBloc.state as SettingsLoaded).themeMode
        : ThemeMode.system;

    final initialLocale = settingsBloc.state is SettingsLoaded
        ? Locale((settingsBloc.state as SettingsLoaded).languageCode)
        : Locale(LocalizationService().currentLocale.code);

    return StreamBuilder<ThemeMode>(
      stream: settingsBloc.themeStream,
      initialData: initialTheme,
      builder: (context, themeSnap) {
        return StreamBuilder<Locale>(
          stream: settingsBloc.localeStream,
          initialData: initialLocale,
          builder: (context, localeSnap) {
            // ValueKey(_rebuildKey) ensures the entire MaterialApp subtree is
            // rebuilt when the locale changes, re-running all .tr calls.
            return KeyedSubtree(
              key: ValueKey(_rebuildKey),
              child: MaterialApp(
                title: 'WiseSpends',
                debugShowCheckedModeBanner: false,
                themeMode: themeSnap.data ?? ThemeMode.system,
                theme: AppTheme.getLightTheme(context),
                darkTheme: AppTheme.getDarkTheme(context),
                locale: localeSnap.data,
                navigatorObservers: [
                  AppRouter.budgetPlanRouteObserver,
                  AppRouter.homeRouteObserver,
                ],
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
                      child: SafeArea(top: false, bottom: true, child: child!),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

void _registerSingletons() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());
}
