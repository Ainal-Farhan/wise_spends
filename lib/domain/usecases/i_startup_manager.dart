import 'dart:async';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/usecases/i_manager.dart';

abstract class IStartupManager extends IManager {
  Future onRunApp(bool? isFirstInit);
  Future refreshCurrentUser();
  CmmnUser get currentUser;
}
