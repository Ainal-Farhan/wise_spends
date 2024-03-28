import 'dart:async';
import 'package:wise_spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_service_locator.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';
import 'package:wise_spends/theme/i_theme_manager.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/manager/i_startup_manager.dart';
import 'package:wise_spends/util/singleton_util.dart';

class StartupManager implements IStartupManager {
  static final IConfigurationManager _configurationManager =
      SingletonUtil.getSingleton<IManagerLocator>().getConfigurationManager();

  static final IThemeManager _themeManager =
      SingletonUtil.getSingleton<IManagerLocator>().getThemeManager();

  final IUserService _userService =
      SingletonUtil.getSingleton<IServiceLocator>().getUserService();

  CmmnUser? _currentUser;

  @override
  Future onRunApp(final String name) async {
    await _initCurrentUser(name);
    await _configurationManager.init();
    await _themeManager.init();
  }

  Future _initCurrentUser(final String name) async {
    if (_currentUser != null) return;

    _currentUser = await _userService.findByName(name);

    if (_currentUser == null) {
      _currentUser = await _addUser(name);
      return;
    }
  }

  Future<CmmnUser> _addUser(final String name) async {
    return await _userService.add(UserTableCompanion.insert(
      name: name,
      dateUpdated: DateTime.now(),
      createdBy: name,
      lastModifiedBy: name,
    ));
  }

  @override
  CmmnUser get currentUser => CmmnUser.fromJson(_currentUser!.toJson());
}
