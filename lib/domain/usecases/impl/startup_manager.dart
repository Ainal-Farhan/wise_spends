import 'dart:async';
import 'package:wise_spends/core/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_service_locator.dart';
import 'package:wise_spends/core/logger/logger.dart';
import 'package:wise_spends/core/services/preferences_service.dart';
import 'package:wise_spends/data/services/local/common/i_user_service.dart';
import 'package:wise_spends/shared/theme/i_theme_manager.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/usecases/i_startup_manager.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';

class StartupManager extends IStartupManager {
  static final IConfigurationManager _configurationManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getConfigurationManager();

  static final IThemeManager _themeManager =
      SingletonUtil.getSingleton<IManagerLocator>()!.getThemeManager();

  final IUserService _userService =
      SingletonUtil.getSingleton<IServiceLocator>()!.getUserService();

  CmmnUser? _currentUser;
  bool isFirstInit = true;

  @override
  Future refreshCurrentUser() async {
    await _initCurrentUser(_currentUser!.name, true, true);
  }

  @override
  Future onRunApp(bool? isFirstInit) async {
    isFirstInit ??= this.isFirstInit;

    if (isFirstInit) {
      _currentUser = null;
    }

    // Initialize logger and preferences
    await _initializeLogger();

    await _initCurrentUser("Guest", true, false);
    await _configurationManager.init();
    await _themeManager.init();

    this.isFirstInit = false;
  }

  /// Initialize logger with preferences
  Future<void> _initializeLogger() async {
    try {
      // Initialize preferences service if not already done
      final prefsService = PreferencesService();
      await prefsService.init();

      // Initialize logger preferences
      final loggerPrefs = LoggerPreferencesService();
      await loggerPrefs.init();

      // Initialize logger
      final logger = WiseLogger();
      await logger.init();

      // Apply preferences
      logger.setEnabled(loggerPrefs.isLoggingEnabled());
      logger.setMinLogLevel(loggerPrefs.getMinLogLevel());

      WiseLogger().info('Logger initialized', tag: 'StartupManager');
    } catch (e, stackTrace) {
      // If logger initialization fails, try to log it
      try {
        WiseLogger().error(
          'Failed to initialize logger: $e',
          tag: 'StartupManager',
          error: e,
          stackTrace: stackTrace,
        );
      } catch (_) {
        // Silent failure - logger couldn't be initialized
      }
    }
  }

  Future _initCurrentUser(
    final String name,
    final bool isFindAnyUser,
    bool isRefresh,
  ) async {
    if (_currentUser != null && !isRefresh) return;

    _currentUser = await _userService.findByName(name);

    if (_currentUser == null && isFindAnyUser) {
      _currentUser = await _userService.findOnlyOneInRandom();
    }

    if (_currentUser == null) {
      _currentUser = await _addUser(name);
      return;
    }
  }

  Future<CmmnUser> _addUser(final String name) async {
    return await _userService.add(
      UserTableCompanion.insert(
        name: name,
        dateUpdated: DateTime.now(),
        createdBy: name,
        lastModifiedBy: name,
      ),
    );
  }

  @override
  CmmnUser get currentUser => CmmnUser.fromJson(_currentUser!.toJson());
}
