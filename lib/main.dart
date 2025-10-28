import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/bloc/impl/login/login_bloc.dart';
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
    ThemeProvider(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LoginBloc>(
            create: (context) => LoginBloc(),
            child: BlocBuilder<LoginBloc, IState<dynamic>>(
              builder: (context, state) => state.build(context),
            ),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class ThemeProvider extends StatefulWidget {
  final Widget child;

  const ThemeProvider({super.key, required this.child});

  static ThemeProviderState? of(BuildContext context) {
    final themeProvider = context
        .dependOnInheritedWidgetOfExactType<_InheritedThemeProvider>();
    return themeProvider?.stateProvider;
  }

  @override
  State<ThemeProvider> createState() => ThemeProviderState();
}

class ThemeProviderState extends State<ThemeProvider> {
  late String currentTheme;
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    currentTheme = SingletonUtil.getSingleton<IManagerLocator>()!
        .getConfigurationManager()
        .getTheme();
    themeMode = _getThemeMode();
  }

  void updateTheme() {
    setState(() {
      currentTheme = SingletonUtil.getSingleton<IManagerLocator>()!
          .getConfigurationManager()
          .getTheme();
      themeMode = _getThemeMode();
    });
  }

  ThemeMode _getThemeMode() {
    return currentTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedThemeProvider(
      stateProvider: this,
      currentTheme: currentTheme,
      themeMode: themeMode,
      child: widget.child,
    );
  }

  ThemeData getThemeData() {
    final themeManager = SingletonUtil.getSingleton<IManagerLocator>()!
        .getThemeManager();
    if (themeMode == ThemeMode.dark) {
      return ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: themeManager.colorTheme.backgroundBlue,
        scaffoldBackgroundColor:
            themeManager.colorTheme.complexDrawerCanvasColor,
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
    } else {
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
  }
}

class _InheritedThemeProvider extends InheritedWidget {
  final ThemeProviderState stateProvider;
  final String currentTheme;
  final ThemeMode themeMode;

  const _InheritedThemeProvider({
    required this.stateProvider,
    required this.currentTheme,
    required this.themeMode,
    required super.child,
  });

  @override
  bool updateShouldNotify(_InheritedThemeProvider oldWidget) {
    return oldWidget.currentTheme != currentTheme ||
        oldWidget.themeMode != themeMode;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);

    return MaterialApp(
      title: 'Wise Spends',
      theme: themeProvider?.getThemeData(),
      darkTheme: themeProvider?.getThemeData(),
      themeMode: themeProvider?.themeMode ?? ThemeMode.system,
      initialRoute: AppRouter.savingsPageRoute,
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
    );
  }
}

void _registerSingleton() {
  SingletonUtil.registerSingleton<IRepositoryLocator>(RepositoryLocator());
  SingletonUtil.registerSingleton<IManagerLocator>(ManagerLocator());
  SingletonUtil.registerSingleton<IServiceLocator>(ServiceLocator());
}
