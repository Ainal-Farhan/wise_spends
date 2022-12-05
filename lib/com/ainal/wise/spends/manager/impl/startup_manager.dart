import 'dart:async';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_startup_manager.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/user_service.dart';

class StartupManager extends IStartupManager {
  StartupManager._privateConstructor();
  static final StartupManager _startupManager =
      StartupManager._privateConstructor();
  factory StartupManager() {
    return _startupManager;
  }

  final UserService _userService = UserService();
  CmmnUser? _currentUser;

  @override
  Future onRunApp(final String name) async {
    await _initCurrentUser(name);
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
    return await _userService.add(UserTableCompanion.insert(name: name));
  }

  @override
  CmmnUser get currentUser => CmmnUser.fromJson(_currentUser!.toJson());
}
