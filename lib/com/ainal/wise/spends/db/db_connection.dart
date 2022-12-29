import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:wise_spends/com/ainal/wise/spends/utils/app_path.dart';

abstract class DbConnection {
  static LazyDatabase openConnection() {
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final file = File(AppPath().setFilePath(
        directory: await AppPath().getApplicationDocumentsDirectory(),
        fileName: 'wise_spends.sqlite',
      ));

      // if (!await file.exists()) {
      //   // Extract the pre-populated database file from assets
      //   final blob = await rootBundle.load('assets/backup.sqlite');
      //   final buffer = blob.buffer;
      //   await file.writeAsBytes(
      //       buffer.asUint8List(blob.offsetInBytes, blob.lengthInBytes));
      // }

      return NativeDatabase(file);
    });
  }
}
