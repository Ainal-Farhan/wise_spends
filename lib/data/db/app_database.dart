import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
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
import 'package:wise_spends/data/db/tables/budget_table.dart';
import 'package:wise_spends/data/db/tables/budget_plan_tables.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Budgets,
    BudgetPlans,
    BudgetPlanDeposits,
    BudgetPlanTransactions,
    BudgetPlanLinkedAccounts,
    BudgetPlanMilestones,
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
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // ── v2 → v3 ───────────────────────────────────────────────────────
        // SQLite cannot change column nullability with ALTER TABLE, so we
        // recreate commitment_detail_table with the correct schema and copy
        // existing data across.
        //
        // Changes vs v2 schema:
        //   saving_id        TEXT NOT NULL  →  TEXT NULLABLE
        //   task_type        (new) INTEGER NOT NULL DEFAULT 0
        //   target_saving_id (new) TEXT NULLABLE
        //   payee_id         (new) TEXT NULLABLE
        //
        // Existing rows keep task_type = 0 (internalTransfer) and NULL for
        // the new FK columns — the old distribute behaviour is preserved.
        if (from < 4) {
          // 1. Create the new table alongside the old one
          await customStatement('''
            CREATE TABLE IF NOT EXISTS commitment_detail_table_new (
              id                TEXT NOT NULL PRIMARY KEY,
              created_by        TEXT NOT NULL,
              date_created      INTEGER NOT NULL DEFAULT (unixepoch()),
              date_updated      INTEGER NOT NULL,
              last_modified_by  TEXT NOT NULL,
              amount            REAL NOT NULL,
              description       TEXT NOT NULL,
              type              INTEGER NOT NULL,
              task_type         INTEGER NOT NULL DEFAULT 0,
              saving_id         TEXT REFERENCES saving_table(id),
              target_saving_id  TEXT REFERENCES saving_table(id),
              payee_id          TEXT REFERENCES payee_table(id),
              commitment_id     TEXT NOT NULL REFERENCES commitment_table(id)
            )
          ''');

          // 2. Copy all existing rows; new columns receive their defaults
          await customStatement('''
            INSERT INTO commitment_detail_table_new
              (id, created_by, date_created, date_updated, last_modified_by,
               amount, description, type, saving_id, commitment_id)
            SELECT
              id, created_by, date_created, date_updated, last_modified_by,
              amount, description, type, saving_id, commitment_id
            FROM commitment_detail_table
          ''');

          // 3. Drop old table and rename new one into place
          await customStatement('DROP TABLE commitment_detail_table');
          await customStatement(
            'ALTER TABLE commitment_detail_table_new '
            'RENAME TO commitment_detail_table',
          );
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

      switch (repo.tableName()) {
        case 'UserTable':
          await repo.saveAll([for (final d in tableData) CmmnUser.fromJson(d)]);
        case 'GroupReferenceTable':
          await repo.saveAll([
            for (final d in tableData) MstrdtGroupReference.fromJson(d),
          ]);
        case 'ReferenceTable':
          await repo.saveAll([
            for (final d in tableData) MstrdtReference.fromJson(d),
          ]);
        case 'ReferenceDataTable':
          await repo.saveAll([
            for (final d in tableData) MstrdtReferenceData.fromJson(d),
          ]);
        case 'ExpenseTable':
          await repo.saveAll([
            for (final d in tableData) ExpnsExpense.fromJson(d),
          ]);
        case 'ExpenseReferenceTable':
          await repo.saveAll([
            for (final d in tableData) MstrdtExpenseReference.fromJson(d),
          ]);
        case 'MoneyStorageTable':
          await repo.saveAll([
            for (final d in tableData) SvngMoneyStorage.fromJson(d),
          ]);
        case 'SavingTable':
          await repo.saveAll([
            for (final d in tableData) SvngSaving.fromJson(d),
          ]);
        case 'TransactionTable':
          await repo.saveAll([
            for (final d in tableData) TrnsctnTransaction.fromJson(d),
          ]);
        case 'CommitmentTable':
          await repo.saveAll([
            for (final d in tableData) ExpnsCommitment.fromJson(d),
          ]);
        case 'CommitmentDetailTable':
          await repo.saveAll([
            for (final d in tableData) ExpnsCommitmentDetail.fromJson(d),
          ]);
        case 'CommitmentTaskTable':
          await repo.saveAll([
            for (final d in tableData) ExpnsCommitmentTask.fromJson(d),
          ]);
        case 'PayeeTable':
          await repo.saveAll([
            for (final d in tableData) ExpnsPayee.fromJson(d),
          ]);
      }
    }
  }
}
