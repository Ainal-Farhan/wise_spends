import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/db_connection.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/expense/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/masterdata/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/notification/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/saving/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/transaction/index.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/uuid_generator.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  ...Common.tableList,
  ...Expense.tableList,
  ...MasterData.tableList,
  ...Notification.tableList,
  ...Saving.tableList,
  ...Transaction.tableList,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase._privateConstructor() : super(DbConnection.openConnection());
  static final AppDatabase _appDatabase = AppDatabase._privateConstructor();
  factory AppDatabase() {
    return _appDatabase;
  }

  @override
  int get schemaVersion => 1;

  Future<void> exportInto(File file) async {
    // Make sure the directory of the target file exists
    await file.parent.create(recursive: true);

    // Override an existing backup, sqlite expects the target file to be empty
    if (file.existsSync()) {
      file.deleteSync();
    }

    await customStatement('VACUUM INTO ?', [file.path]);
  }

  Future<bool> restore() async {
    try {
      final filePicker = await FilePicker.platform.pickFiles(
        allowMultiple: false,
      );
      if (filePicker != null && filePicker.count == 1) {
        File file = File(filePicker.files.single.path ?? '');
        await DbConnection.dbFile.writeAsBytes(await file.readAsBytes());
        return true;
      }
    } catch (_) {}

    return false;
  }
}
