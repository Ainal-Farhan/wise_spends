import 'dart:async';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/utils/singleton_util.dart';

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

    await _initCurrentUser("Guest", true, false);
    await _configurationManager.init();
    await _themeManager.init();

    this.isFirstInit = false;
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
