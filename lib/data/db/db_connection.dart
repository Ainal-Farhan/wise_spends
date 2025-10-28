import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:wise_spends/core/utils/app_path.dart';

abstract class DbConnection {
  static late File dbFile;
  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      dbFile = File(AppPath().setFilePath(
        directory: await AppPath().getApplicationDocumentsDirectory(),
        fileName: 'wise_spends.sqlite',
      ));

      return NativeDatabase(dbFile);
    });
  }
}
