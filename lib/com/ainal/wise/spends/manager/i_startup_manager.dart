import 'dart:async';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/manager/i_manager.dart';

abstract class IStartupManager extends IManager {
  Future onRunApp(final String name);
  CmmnUser get currentUser;
}
