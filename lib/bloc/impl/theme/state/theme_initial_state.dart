import 'package:flutter/material.dart';
import 'package:wise_spends/bloc/i_state.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/router/app_router.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class ThemeInitialState extends IState<ThemeInitialState> {
  const ThemeInitialState({required super.version});

  @override
  String toString() => 'ThemeInitialState';

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
    final themeManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getThemeManager();
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
    final themeManager =
        SingletonUtil.getSingleton<IManagerLocator>()!.getThemeManager();
    return ThemeData.dark().copyWith(
      brightness: Brightness.dark,
      primaryColor: themeManager.colorTheme.primaryColor,
      scaffoldBackgroundColor: themeManager.colorTheme.complexDrawerCanvasColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeManager.colorTheme.backgroundBlue,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeManager.colorTheme.primaryColor,
        brightness: Brightness.dark,
      ).copyWith(
        onSurface: Colors.white,  // For text on dark surfaces
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

  @override
  ThemeInitialState getNewVersion() => ThemeInitialState(version: version + 1);

  @override
  ThemeInitialState getStateCopy() => ThemeInitialState(version: version);
}
