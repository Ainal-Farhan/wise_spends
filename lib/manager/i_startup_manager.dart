import 'dart:async';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/manager/i_manager.dart';

abstract class IStartupManager extends IManager {
  Future onRunApp(final String name, final bool isFindAnyUserIfNotExist);
  CmmnUser get currentUser;
}
