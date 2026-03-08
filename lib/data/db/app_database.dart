import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_task_type.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/app_path.dart';
import 'package:wise_spends/core/utils/file_util.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/db_connection.dart';
import 'package:wise_spends/data/db/domain/common/index.dart';
import 'package:wise_spends/data/db/domain/expense/index.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/data/db/domain/masterdata/index.dart';
import 'package:wise_spends/data/db/domain/saving/index.dart';
import 'package:wise_spends/data/db/domain/transaction/index.dart';
import 'package:wise_spends/data/db/domain/budget/index.dart';
import 'package:wise_spends/data/db/domain/savings_plan/index.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ...Budget.tableList,
    ...SavingsPlan.tableList,
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
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Migration to schema version 2: Add item tracking tables
          // Add itemId column to SavingsPlanDepositTable
          await m.addColumn(savingsPlanDepositTable, savingsPlanDepositTable.itemId);
          // Add itemId column to SavingsPlanSpendingTable
          await m.addColumn(savingsPlanSpendingTable, savingsPlanSpendingTable.itemId);
          // Create new tables (SavingsPlanItemTable and SavingsPlanItemTagTable are auto-created)
          await m.create(savingsPlanItemTable);
          await m.create(savingsPlanItemTagTable);
        }
      },
    );
  }

  Future<String> exportInto(final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    final dir = await AppPath().getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/temp_backup');

    if (!(await backupDir.exists())) {
      await backupDir.create(recursive: true);
    }

    final String fullPath = path.join(dir.path, 'temp_backup');

    final File file = FileUtil.createFileWithCurrentDateTime(
      path: fullPath,
      fileName: 'backup',
      extension: ext,
    );

    if (file.existsSync()) file.deleteSync();

    FileUtil.createFileIntoDirectory(file);
    if (isJson) {
      Map<String, dynamic> data = await retrieveDataFromAllTables();
      await file.writeAsString(jsonEncode(data));
    } else {
      await customStatement('VACUUM INTO ?', [file.path]);
    }
    return file.path;
  }

  Future<Directory> getAppMediaDirectory() async {
    final Directory? baseDir = await getExternalStorageDirectory();
    if (baseDir == null) throw Exception('External storage not available');

    final mediaDir = Directory(
      path.join(
        '/storage/emulated/0/Android/media',
        'com.my.aftechlabs.wise.spends',
      ),
    );

    if (!(await mediaDir.exists())) {
      await mediaDir.create(recursive: true);
    }
    return mediaDir;
  }

  Future<String> getBackupFolderPath() async {
    final Directory dir = await getAppMediaDirectory();
    final backupDir = Directory(path.join(dir.path, 'backup', 'db'));
    if (!(await backupDir.exists())) {
      await backupDir.create(recursive: true);
    }
    return backupDir.path;
  }

  Future<String> exportToInternalStorageMedia(final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    String backupPath = await getBackupFolderPath();

    final File file = FileUtil.createFileWithCurrentDateTime(
      path: backupPath,
      fileName: 'backup',
      extension: ext,
    );

    if (file.existsSync()) file.deleteSync();

    FileUtil.createFileIntoDirectory(file);
    if (isJson) {
      Map<String, dynamic> data = await retrieveDataFromAllTables();
      await file.writeAsString(jsonEncode(data));
    } else {
      await customStatement('VACUUM INTO ?', [file.path]);
    }
    return file.path;
  }

  Future<bool> restore(final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    String backupPath = await getBackupFolderPath();

    final filePicker = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['sqlite', 'json'],
      initialDirectory: backupPath,
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
        throw 'The file extension is ${FileUtil.getFileExtension(file)}, '
            'it must be ${allowedExtensions.join(" or ")}';
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
      final List<DataClass> rows = await repo.findAll();
      for (final row in rows) {
        data[repo.tableName()].add(row.toJson());
      }
    }
    return data;
  }

  Future replaceDataFromTable(Map<String, dynamic> data) async {
    for (final repo
        in SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()) {
      await repo.deleteAll();

      final tableData = data[repo.tableName()];
      if (tableData == null) continue;

      try {
        switch (repo.tableName()) {
          case 'UserTable':
            final users = (tableData as List)
                .map((d) => CmmnUser.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(users);
            break;
          case 'GroupReferenceTable':
            final refs = (tableData as List)
                .map(
                  (d) =>
                      MstrdtGroupReference.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(refs);
            break;
          case 'ReferenceTable':
            final refs = (tableData as List)
                .map((d) => MstrdtReference.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(refs);
            break;
          case 'ReferenceDataTable':
            final refs = (tableData as List)
                .map(
                  (d) =>
                      MstrdtReferenceData.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(refs);
            break;
          case 'ExpenseTable':
            final expenses = (tableData as List)
                .map((d) => ExpnsExpense.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(expenses);
            break;
          case 'ExpenseReferenceTable':
            final refs = (tableData as List)
                .map(
                  (d) => MstrdtExpenseReference.fromJson(
                    d as Map<String, dynamic>,
                  ),
                )
                .toList();
            await repo.saveAll(refs);
            break;
          case 'MoneyStorageTable':
            final storages = (tableData as List)
                .map(
                  (d) => SvngMoneyStorage.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(storages);
            break;
          case 'SavingTable':
            final savings = (tableData as List)
                .map((d) => SvngSaving.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(savings);
            break;
          case 'TransactionTable':
            final transactions = (tableData as List)
                .map(
                  (d) => TrnsctnTransaction.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(transactions);
            break;
          case 'CommitmentTable':
            final commitments = (tableData as List)
                .map((d) => ExpnsCommitment.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(commitments);
            break;
          case 'CommitmentDetailTable':
            final details = (tableData as List)
                .map(
                  (d) =>
                      ExpnsCommitmentDetail.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(details);
            break;
          case 'CommitmentTaskTable':
            final tasks = (tableData as List)
                .map(
                  (d) =>
                      ExpnsCommitmentTask.fromJson(d as Map<String, dynamic>),
                )
                .toList();
            await repo.saveAll(tasks);
            break;
          case 'PayeeTable':
            final payees = (tableData as List)
                .map((d) => ExpnsPayee.fromJson(d as Map<String, dynamic>))
                .toList();
            await repo.saveAll(payees);
            break;
        }
      } catch (e) {
        // Log error but continue with other tables
        // In production, use proper logging
      }
    }
  }
}
