import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:wise_spends/db/db_connection.dart';
import 'package:wise_spends/db/domain/common/index.dart';
import 'package:wise_spends/db/domain/expense/index.dart';
import 'package:wise_spends/db/domain/masterdata/index.dart';
import 'package:wise_spends/db/domain/saving/index.dart';
import 'package:wise_spends/db/domain/transaction/index.dart';
import 'package:wise_spends/locator/i_manager_locator.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/utils/app_path.dart';
import 'package:wise_spends/utils/file_util.dart';
import 'package:wise_spends/utils/permission_util.dart';
import 'package:wise_spends/utils/singleton_util.dart';
import 'package:wise_spends/utils/uuid_generator.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ...Common.tableList,
    ...MasterData.tableList,
    ...Saving.tableList,
    ...Expense.tableList,
    ...Transaction.tableList,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._privateConstructor() : super(DbConnection.openConnection());
  static final AppDatabase _appDatabase = AppDatabase._privateConstructor();
  factory AppDatabase() {
    return _appDatabase;
  }

  @override
  int get schemaVersion => 1;

  Future<String> exportInto(final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    final File file = FileUtil.createFileWithCurrentDateTime(
      path: '${await AppPath().getDownloadsDirectory()}/backup/db',
      fileName: 'backup',
      extension: ext,
    );

    if (await PermissionUtil.isManageExternalStoragePermissionGranted()) {
      if (file.existsSync()) {
        file.deleteSync();
      }

      FileUtil.createFileIntoDirectory(file);
      if (isJson) {
        Map<String, dynamic> data = await retrieveDataFromAllTables();

        String jsonString = jsonEncode(data);

        await file.writeAsString(jsonString);
      } else {
        await customStatement('VACUUM INTO ?', [file.path]);
      }
      return file.path;
    }

    throw 'Permission Manage External Storage is not granted';
  }

  Future<bool> restore(final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    final filePicker = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.any,
    );
    if (filePicker != null && filePicker.count == 1) {
      File file = File(filePicker.files.single.path ?? '');

      final List<String> allowedExtensions = [ext];

      if (FileUtil.isMatchCustomExtensions(
        file: file,
        allowedExtensions: allowedExtensions,
      )) {
        if (isJson) {
          await replaceDataFromTable(
            await FileUtil.decodeFromJsonFile(jsonFile: file),
          );
        } else {
          await DbConnection.dbFile.writeAsBytes(await file.readAsBytes());
        }

        await SingletonUtil.getSingleton<IManagerLocator>()
            ?.getStartupManager()
            .onRunApp(true);

        return true;
      } else {
        throw 'The file extension is ${FileUtil.getFileExtension(file)}, it must be ${allowedExtensions.join(" or ")}';
      }
    }
    return false;
  }

  Future<Map<String, dynamic>> retrieveDataFromAllTables() async {
    Map<String, dynamic> data = {};

    for (final repo
        in SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()) {
      data[repo.tableName()] = [];
      List<DataClass> dataClassList = await repo.findAll();

      if (dataClassList.isNotEmpty) {
        for (DataClass dataClass in dataClassList) {
          data[repo.tableName()].add(dataClass.toJson());
        }
      }
    }

    return data;
  }

  Future replaceDataFromTable(Map<String, dynamic> data) async {
    for (final repo
        in SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()) {
      await repo.deleteAll();

      if (data[repo.tableName()] != null) {
        if (repo.tableName() == 'UserTable') {
          List<CmmnUser> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(CmmnUser.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'GroupReferenceTable') {
          List<MstrdtGroupReference> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(MstrdtGroupReference.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'ReferenceTable') {
          List<MstrdtReference> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(MstrdtReference.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'ReferenceDataTable') {
          List<MstrdtReferenceData> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(MstrdtReferenceData.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'ExpenseTable') {
          List<ExpnsExpense> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(ExpnsExpense.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'ExpenseReferenceTable') {
          List<MstrdtExpenseReference> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(MstrdtExpenseReference.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'MoneyStorageTable') {
          List<SvngMoneyStorage> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(SvngMoneyStorage.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'SavingTable') {
          List<SvngSaving> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(SvngSaving.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'TransactionTable') {
          List<TrnsctnTransaction> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(TrnsctnTransaction.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'CommitmentTable') {
          List<ExpnsCommitment> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(ExpnsCommitment.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'CommitmentDetailTable') {
          List<ExpnsCommitmentDetail> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(ExpnsCommitmentDetail.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }

        if (repo.tableName() == 'CommitmentTaskTable') {
          List<ExpnsCommitmentTask> items = [];
          for (final dataInJson in data[repo.tableName()]) {
            items.add(ExpnsCommitmentTask.fromJson(dataInJson));
          }
          await repo.saveAll(items);
          continue;
        }
      }
    }
  }
}
