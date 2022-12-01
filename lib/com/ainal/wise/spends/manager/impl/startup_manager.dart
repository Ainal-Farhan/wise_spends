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
  CmnUser? _currentUser;

  @override
  Future onRunApp(final String name) async {
    await _initCurrentUser(name);
  }

  Future _initCurrentUser(final String name) async {
    if (_currentUser!.id.isNotEmpty) return;

    _currentUser = _userService.findByName(name) as CmnUser;

    if (_currentUser == null) {
      _currentUser = await _addUser(name);
      return;
    }
  }

  Future<CmnUser> _addUser(final String name) async {
    return await _userService.add(UserTableCompanion.insert(name: name));
  }
}
