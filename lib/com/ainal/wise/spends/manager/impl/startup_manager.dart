import 'dart:async';
import 'package:wise_spends/com/ainal/wise/spends/config/configuration/configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/config/configuration/i_configuration_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/theme/i_theme_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/common/impl/user_service.dart';

class StartupManager implements IStartupManager {
  StartupManager._privateConstructor();
  static final StartupManager _startupManager =
      StartupManager._privateConstructor();
  factory StartupManager() {
    return _startupManager;
  }

  static final IConfigurationManager _configurationManager =
      ConfigurationManager();

  static final IThemeManager _themeManager = IThemeManager();

  final UserService _userService = UserService();
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
    return await _userService.add(
        UserTableCompanion.insert(name: name, dateUpdated: DateTime.now()));
  }

  @override
  CmmnUser get currentUser => CmmnUser.fromJson(_currentUser!.toJson());
}
