import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/app_path.dart';

abstract class DbConnection {
  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      final file = File(AppPath().setFilePath(
        directory: await AppPath().getApplicationDocumentsDirectory(),
        fileName: 'db.sqlite',
      ));
      return NativeDatabase(file);
    });
  }
}
