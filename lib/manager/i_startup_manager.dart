import 'dart:async';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/manager/i_manager.dart';
import 'package:wise_spends/manager/impl/startup_manager.dart';

abstract class IStartupManager extends IManager {
  factory IStartupManager() {
    return StartupManager();
  }

  Future onRunApp(final String name);
  CmmnUser get currentUser;
}
