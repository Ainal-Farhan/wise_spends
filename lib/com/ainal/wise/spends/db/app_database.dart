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
import 'package:wise_spends/com/ainal/wise/spends/utils/app_path.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/file_util.dart';
import 'package:wise_spends/com/ainal/wise/spends/utils/permission_util.dart';
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

  Future<String> exportInto() async {
    final File file = FileUtil.createFileWithCurrentDateTime(
      path: '${await AppPath().getDownloadsDirectory()}/backup/db',
      fileName: 'backup',
      extension: 'sqlite',
    );

    if (await PermissionUtil.isManageExternalStoragePermissionGranted()) {
      if (file.existsSync()) {
        file.deleteSync();
      }

      FileUtil.createFileIntoDirectory(file);
      await customStatement('VACUUM INTO ?', [file.path]);

      return file.path;
    }

    throw 'Permission Manage External Storage is not granted';
  }

  Future<bool> restore() async {
    final filePicker = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (filePicker != null && filePicker.count == 1) {
      File file = File(filePicker.files.single.path ?? '');

      final List<String> allowedExtensions = ['sqlite'];

      if (FileUtil.isMatchCustomExtensions(
        file: file,
        allowedExtensions: allowedExtensions,
      )) {
        await DbConnection.dbFile.writeAsBytes(await file.readAsBytes());
        return true;
      } else {
        throw 'The file extension is ${FileUtil.getFileExtension(file)}, it must be ${allowedExtensions.join(" or ")}';
      }
    }
    return false;
  }
}
