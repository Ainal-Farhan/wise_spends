import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_enum.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_detail_type.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/core/di/i_manager_locator.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/logger/wise_logger.dart';
import 'package:wise_spends/core/utils/app_path.dart';
import 'package:wise_spends/core/utils/file_util.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/db_connection.dart';
import 'package:wise_spends/data/db/domain/common/index.dart';
import 'package:wise_spends/data/db/domain/common/file_storage_table.dart';
import 'package:wise_spends/data/db/domain/expense/index.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/data/db/domain/masterdata/index.dart';
import 'package:wise_spends/data/db/domain/saving/index.dart';
import 'package:wise_spends/data/db/domain/transaction/index.dart';
import 'package:wise_spends/data/db/domain/budget/index.dart';
import 'package:wise_spends/data/db/domain/savings_plan/index.dart';
import 'package:wise_spends/data/db/domain/credit_card/index.dart';
import 'package:wise_spends/data/db/domain/loan/index.dart';
import 'package:wise_spends/data/db/domain/lending/index.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    ...Common.tableList,
    ...Budget.tableList,
    ...SavingsPlan.tableList,
    ...MasterData.tableList,
    ...Saving.tableList,
    ...Expense.tableList,
    ...Transaction.tableList,
    ...CreditCard.tableList,
    ...Loan.tableList,
    ...Lending.tableList,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase._privateConstructor() : super(DbConnection.openConnection());
  static final AppDatabase _appDatabase = AppDatabase._privateConstructor();
  factory AppDatabase() {
    return _appDatabase;
  }

  @override
  int get schemaVersion => 11;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(creditCardTable);
          await m.createTable(creditCardChargeTable);
          await m.createTable(creditCardPaymentTable);
          await m.createTable(creditCardChargePaymentTable);
          await m.createTable(loanTable);
          await m.createTable(loanRepaymentTable);
        }
        if (from < 3) {
          await m.addColumn(transactionTable, transactionTable.loanId);
        }
        if (from < 4) {
          await m.addColumn(
            creditCardChargeTable,
            creditCardChargeTable.reservedSavingId,
          );
        }
        if (from < 5) {
          await m.addColumn(
            loanTable,
            loanTable.noAutoDeduct as GeneratedColumn,
          );
        }
        if (from < 6) {
          await m.addColumn(
            creditCardChargeTable,
            creditCardChargeTable.status as GeneratedColumn,
          );
          await m.addColumn(
            creditCardChargeTable,
            creditCardChargeTable.isRebate as GeneratedColumn,
          );
        }
        if (from < 7) {
          await m.addColumn(
            commitmentDetailTable,
            commitmentDetailTable.linkedCreditCardId,
          );
          await m.addColumn(
            commitmentDetailTable,
            commitmentDetailTable.eppTotalInstallments,
          );
          await m.addColumn(
            commitmentDetailTable,
            commitmentDetailTable.eppCompletedInstallments as GeneratedColumn,
          );
        }
        if (from < 8) {
          await m.addColumn(
            creditCardChargePaymentTable,
            creditCardChargePaymentTable.deductedSavingId,
          );
        }
        if (from < 9) {
          await m.addColumn(savingTable, savingTable.displayOrder);
          await m.addColumn(moneyStorageTable, moneyStorageTable.displayOrder);
        }
        if (from < 10) {
          await m.createTable(lendingTable);
          await m.createTable(lendingRepaymentTable);
          await m.addColumn(transactionTable, transactionTable.lendingId);
        }
        if (from < 11) {
          await m.addColumn(
            creditCardTable,
            creditCardTable.cardType as GeneratedColumn,
          );
          await m.addColumn(creditCardTable, creditCardTable.providerName);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
        if (!details.wasCreated) {
          await _repairLatestSchemaData();
        }
      },
    );
  }

  Future<void> _repairLatestSchemaData() async {
    await transaction(() async {
      await _repairMoneyStorageDisplayOrder();
      await _repairSavingDisplayOrder();
      await _repairMissingCommitmentDetails();
    });
  }

  Future<void> _repairMoneyStorageDisplayOrder() async {
    final rows =
        await (select(moneyStorageTable)..orderBy([
              (tbl) => OrderingTerm.asc(tbl.displayOrder),
              (tbl) => OrderingTerm.asc(tbl.dateCreated),
            ]))
            .get();
    if (!_needsDisplayOrderRepair(rows.map((row) => row.displayOrder))) {
      return;
    }

    for (var index = 0; index < rows.length; index++) {
      await (update(moneyStorageTable)
            ..where((tbl) => tbl.id.equals(rows[index].id)))
          .write(MoneyStorageTableCompanion(displayOrder: Value(index)));
    }
  }

  Future<void> _repairSavingDisplayOrder() async {
    final rows =
        await (select(savingTable)..orderBy([
              (tbl) => OrderingTerm.asc(tbl.displayOrder),
              (tbl) => OrderingTerm.asc(tbl.dateCreated),
            ]))
            .get();
    if (!_needsDisplayOrderRepair(rows.map((row) => row.displayOrder))) {
      return;
    }

    for (var index = 0; index < rows.length; index++) {
      await (update(savingTable)..where((tbl) => tbl.id.equals(rows[index].id)))
          .write(SavingTableCompanion(displayOrder: Value(index)));
    }
  }

  bool _needsDisplayOrderRepair(Iterable<int> values) {
    final list = values.toList();
    return list.length > 1 && list.toSet().length != list.length;
  }

  Future<void> _repairMissingCommitmentDetails() async {
    final existingDetails = await select(commitmentDetailTable).get();
    final existingDetailIds = existingDetails.map((row) => row.id).toSet();
    final tasks = await select(commitmentTaskTable).get();

    for (final task in tasks) {
      if (existingDetailIds.contains(task.commitmentDetailId)) continue;

      existingDetailIds.add(task.commitmentDetailId);
      await into(commitmentDetailTable).insert(
        CommitmentDetailTableCompanion.insert(
          id: Value(task.commitmentDetailId),
          createdBy: task.createdBy,
          dateCreated: Value(task.dateCreated),
          dateUpdated: task.dateUpdated,
          lastModifiedBy: task.lastModifiedBy,
          amount: task.amount,
          description: task.name,
          type: CommitmentDetailType.oneOff,
          taskType: Value(task.type),
          savingId: Value(task.sourceSavingId),
          targetSavingId: Value(task.targetSavingId),
          payeeId: Value(task.payeeId),
          commitmentId: task.commitmentId,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
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
      type: isJson ? FileType.custom : FileType.any,
      allowedExtensions: isJson ? ['json'] : null,
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
    final normalizedData = _normalizeRestoreData(data);
    final repositories =
        SingletonUtil.getSingleton<IRepositoryLocator>()!
            .retrieveAllRepository()
          ..sort(
            (a, b) => _restoreTablePriority(
              a.tableName(),
            ).compareTo(_restoreTablePriority(b.tableName())),
          );

    await transaction(() async {
      for (final repo in repositories.reversed) {
        await repo.deleteAll();
      }

      for (final repo in repositories) {
        final tableData = normalizedData[repo.tableName()];
        if (tableData == null) continue;

        try {
          final List<Map<String, dynamic>> jsonList = (tableData as List)
              .whereType<Map>()
              .map<Map<String, dynamic>>(
                (row) => Map<String, dynamic>.from(row),
              )
              .toList();
          await repo.saveAllFromJson(jsonList);
        } catch (e, stackTrace) {
          WiseLogger().error(
            "Error while restoring ${repo.tableName()}",
            error: e,
            stackTrace: stackTrace,
          );
          throw Exception('Failed to restore ${repo.tableName()}: $e');
        }
      }
    });
  }

  int _restoreTablePriority(String tableName) {
    const priorities = {
      'UserTable': 10,
      'GroupReferenceTable': 20,
      'ReferenceTable': 21,
      'ReferenceDataTableTable': 22,
      'CategoryTable': 30,
      'PayeeTable': 31,
      'MoneyStorageTable': 32,
      'SavingTable': 40,
      'CreditCardTable': 41,
      'LoanTable': 42,
      'LendingTable': 43,
      'CommitmentTable': 43,
      'SpendingBudgetTable': 44,
      'SavingsPlanTable': 45,
      'CommitmentDetailTable': 50,
      'CommitmentTaskTable': 51,
      'CreditCardChargeTable': 52,
      'CreditCardPaymentTable': 53,
      'LoanRepaymentTable': 54,
      'LendingRepaymentTable': 55,
      'SavingsPlanItemTable': 55,
      'SavingsPlanDepositTable': 56,
      'SavingsPlanSpendingTable': 57,
      'SavingsPlanMilestoneTable': 58,
      'SavingsPlanLinkedAccountTable': 59,
      'SavingsPlanItemTagTable': 60,
      'TransactionTable': 70,
      'TransactionTagTable': 71,
      'TransactionTagMapTable': 72,
      'RecurringTransactionTable': 73,
      'TransactionRevokeTable': 74,
      'CreditCardChargePaymentTable': 75,
      'ExpenseTable': 80,
      'ExpenseReferenceTable': 81,
      'FileStorageTable': 90,
    };

    return priorities[tableName] ?? 1000;
  }

  Map<String, dynamic> _normalizeRestoreData(Map<String, dynamic> data) {
    final normalized = <String, dynamic>{};

    for (final entry in data.entries) {
      final tableData = entry.value;
      if (tableData is! List) {
        normalized[entry.key] = tableData;
        continue;
      }

      normalized[entry.key] = tableData
          .asMap()
          .entries
          .where((rowEntry) => rowEntry.value is Map)
          .map(
            (rowEntry) => _normalizeRestoreRow(
              entry.key,
              Map<String, dynamic>.from(rowEntry.value as Map),
              rowEntry.key,
            ),
          )
          .toList();
    }

    _backfillMissingMoneyStorageForSavings(normalized);
    _backfillMissingCommitmentsForTasks(normalized);
    _backfillCommitmentDetails(normalized);
    _clearMissingOptionalReferences(normalized);

    return normalized;
  }

  void _clearMissingOptionalReferences(Map<String, dynamic> normalized) {
    final userIds = _restoreIds(normalized, 'UserTable');
    final categoryIds = _restoreIds(normalized, 'CategoryTable');
    final savingIds = _restoreIds(normalized, 'SavingTable');
    final payeeIds = _restoreIds(normalized, 'PayeeTable');
    final commitmentTaskIds = _restoreIds(normalized, 'CommitmentTaskTable');
    final loanIds = _restoreIds(normalized, 'LoanTable');
    final creditCardIds = _restoreIds(normalized, 'CreditCardTable');

    _nullMissingRef(normalized, 'MoneyStorageTable', 'userId', userIds);
    _nullMissingRef(normalized, 'SavingTable', 'userId', userIds);
    _nullMissingRef(normalized, 'SavingTable', 'categoryId', categoryIds);

    _nullMissingRef(
      normalized,
      'TransactionTable',
      'destinationSavingId',
      savingIds,
    );
    _nullMissingRef(normalized, 'TransactionTable', 'categoryId', categoryIds);
    _nullMissingRef(
      normalized,
      'TransactionTable',
      'commitmentTaskId',
      commitmentTaskIds,
    );
    _nullMissingRef(normalized, 'TransactionTable', 'payeeId', payeeIds);
    _nullMissingRef(normalized, 'TransactionTable', 'loanId', loanIds);
    final lendingIds = _restoreIds(normalized, 'LendingTable');
    _nullMissingRef(normalized, 'TransactionTable', 'lendingId', lendingIds);
    _nullMissingRef(normalized, 'LendingTable', 'userId', userIds);

    _nullMissingRef(normalized, 'CommitmentDetailTable', 'savingId', savingIds);
    _nullMissingRef(
      normalized,
      'CommitmentDetailTable',
      'targetSavingId',
      savingIds,
    );
    _nullMissingRef(normalized, 'CommitmentDetailTable', 'payeeId', payeeIds);
    _nullMissingRef(
      normalized,
      'CommitmentDetailTable',
      'linkedCreditCardId',
      creditCardIds,
    );
    _nullMissingRef(
      normalized,
      'CommitmentTaskTable',
      'sourceSavingId',
      savingIds,
    );
    _nullMissingRef(
      normalized,
      'CommitmentTaskTable',
      'targetSavingId',
      savingIds,
    );
    _nullMissingRef(normalized, 'CommitmentTaskTable', 'payeeId', payeeIds);
    _nullMissingRef(
      normalized,
      'CommitmentTaskTable',
      'transactionId',
      _restoreIds(normalized, 'TransactionTable'),
    );

    _nullMissingRef(normalized, 'CreditCardTable', 'userId', userIds);
    _nullMissingRef(
      normalized,
      'CreditCardChargeTable',
      'categoryId',
      categoryIds,
    );
    _nullMissingRef(
      normalized,
      'CreditCardChargeTable',
      'reservedSavingId',
      savingIds,
    );
    _nullMissingRef(
      normalized,
      'CreditCardChargePaymentTable',
      'deductedSavingId',
      savingIds,
    );

    _nullMissingRef(normalized, 'LoanTable', 'userId', userIds);
  }

  Set<String> _restoreIds(Map<String, dynamic> normalized, String tableName) {
    return (normalized[tableName] as List?)
            ?.whereType<Map>()
            .map((row) => row['id'])
            .whereType<String>()
            .toSet() ??
        <String>{};
  }

  void _backfillMissingMoneyStorageForSavings(Map<String, dynamic> normalized) {
    final savingRows =
        (normalized['SavingTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    if (savingRows.isEmpty) return;

    final moneyStorageRows =
        (normalized['MoneyStorageTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    final moneyStorageIds = moneyStorageRows
        .map((row) => row['id'])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final orphanedSavings = savingRows.where((row) {
      final moneyStorageId = row['moneyStorageId'];
      return moneyStorageId is! String ||
          moneyStorageId.trim().isEmpty ||
          !moneyStorageIds.contains(moneyStorageId);
    }).toList();
    if (orphanedSavings.isEmpty) return;

    const fallbackStorageId = 'restored-unassigned-money-storage';
    if (!moneyStorageIds.contains(fallbackStorageId)) {
      final firstSaving = orphanedSavings.first;
      final existingShortNames = moneyStorageRows
          .map((row) => row['shortName'])
          .whereType<String>()
          .toSet();
      final existingLongNames = moneyStorageRows
          .map((row) => row['longName'])
          .whereType<String>()
          .toSet();
      final shortName = _uniqueRestoreName('Restored', existingShortNames);
      final longName = _uniqueRestoreName(
        'Restored Unassigned',
        existingLongNames,
      );
      moneyStorageRows.add(
        _normalizeRestoreRow('MoneyStorageTable', {
          'id': fallbackStorageId,
          'createdBy': firstSaving['createdBy'] ?? 'restore',
          'dateCreated': firstSaving['dateCreated'],
          'dateUpdated': firstSaving['dateUpdated'],
          'lastModifiedBy': firstSaving['lastModifiedBy'] ?? 'restore',
          'iconUrl': '',
          'longName': longName,
          'shortName': shortName,
          'type': 'General',
          'userId': firstSaving['userId'],
        }, moneyStorageRows.length),
      );
      normalized['MoneyStorageTable'] = moneyStorageRows;
    }

    for (final saving in orphanedSavings) {
      saving['moneyStorageId'] = fallbackStorageId;
    }
  }

  String _uniqueRestoreName(String baseName, Set<String> existingNames) {
    if (!existingNames.contains(baseName)) return baseName;

    var suffix = 2;
    while (existingNames.contains('$baseName $suffix')) {
      suffix++;
    }
    return '$baseName $suffix';
  }

  void _backfillMissingCommitmentsForTasks(Map<String, dynamic> normalized) {
    final taskRows =
        (normalized['CommitmentTaskTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    final detailRows =
        (normalized['CommitmentDetailTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    if (taskRows.isEmpty && detailRows.isEmpty) return;

    final savingRows =
        (normalized['SavingTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    final savingIds = savingRows
        .map((row) => row['id'])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();
    if (savingIds.isEmpty) return;

    final userRows =
        (normalized['UserTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    final userIds = userRows
        .map((row) => row['id'])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    final commitmentRows =
        (normalized['CommitmentTable'] as List?)
            ?.whereType<Map>()
            .map((row) => row)
            .toList() ??
        <Map>[];
    final commitmentIds = commitmentRows
        .map((row) => row['id'])
        .whereType<String>()
        .where((id) => id.trim().isNotEmpty)
        .toSet();

    const fallbackCommitmentId = 'restored-unassigned-commitment';
    var needsFallbackCommitment = false;
    Map? fallbackSourceRow;

    for (final detail in detailRows) {
      final commitmentId = detail['commitmentId'];
      if (commitmentId is! String ||
          commitmentId.trim().isEmpty ||
          !commitmentIds.contains(commitmentId)) {
        detail['commitmentId'] = fallbackCommitmentId;
        fallbackSourceRow ??= detail;
        needsFallbackCommitment = true;
      }
    }

    for (final task in taskRows) {
      final commitmentId = task['commitmentId'];
      if (commitmentId is! String ||
          commitmentId.trim().isEmpty ||
          !commitmentIds.contains(commitmentId)) {
        task['commitmentId'] = fallbackCommitmentId;
        fallbackSourceRow ??= task;
        needsFallbackCommitment = true;
      }

      final commitmentDetailId = task['commitmentDetailId'];
      if (commitmentDetailId is! String || commitmentDetailId.trim().isEmpty) {
        task['commitmentDetailId'] = 'restored-detail-${task['id']}';
      }
    }

    if (needsFallbackCommitment &&
        !commitmentIds.contains(fallbackCommitmentId)) {
      final sourceRow =
          fallbackSourceRow ??
          (taskRows.isNotEmpty ? taskRows.first : detailRows.first);
      final sourceSavingId =
          sourceRow['sourceSavingId'] ?? sourceRow['savingId'];
      final referredSavingId =
          sourceSavingId is String && savingIds.contains(sourceSavingId)
          ? sourceSavingId
          : savingIds.first;
      final saving = savingRows.firstWhere(
        (row) => row['id'] == referredSavingId,
        orElse: () => savingRows.first,
      );
      final userId =
          saving['userId'] is String && userIds.contains(saving['userId'])
          ? saving['userId']
          : userIds.isNotEmpty
          ? userIds.first
          : null;

      commitmentRows.add(
        _normalizeRestoreRow('CommitmentTable', {
          'id': fallbackCommitmentId,
          'createdBy': sourceRow['createdBy'] ?? 'restore',
          'dateCreated': sourceRow['dateCreated'],
          'dateUpdated': sourceRow['dateUpdated'],
          'lastModifiedBy': sourceRow['lastModifiedBy'] ?? 'restore',
          'name': 'Restored Unassigned',
          'description': 'Items restored without commitment links.',
          'referredSavingId': referredSavingId,
          'userId': userId,
        }, commitmentRows.length),
      );
      normalized['CommitmentTable'] = commitmentRows;
    }
  }

  void _nullMissingRef(
    Map<String, dynamic> normalized,
    String tableName,
    String fieldName,
    Set<String> validIds,
  ) {
    final rows = normalized[tableName];
    if (rows is! List) return;

    for (final row in rows.whereType<Map>()) {
      final value = row[fieldName];
      if (value is String &&
          (value.trim().isEmpty || !validIds.contains(value))) {
        row[fieldName] = null;
      }
    }
  }

  void _backfillCommitmentDetails(Map<String, dynamic> normalized) {
    final detailRows =
        (normalized['CommitmentDetailTable'] as List?)
            ?.whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList() ??
        <Map<String, dynamic>>[];
    final taskRows =
        (normalized['CommitmentTaskTable'] as List?)
            ?.whereType<Map>()
            .map((row) => Map<String, dynamic>.from(row))
            .toList() ??
        <Map<String, dynamic>>[];

    if (taskRows.isEmpty) return;

    final existingDetailIds = detailRows
        .map((row) => row['id'])
        .whereType<String>()
        .toSet();
    final synthesizedDetails = <Map<String, dynamic>>[];

    for (final task in taskRows) {
      final detailId = task['commitmentDetailId'];
      final commitmentId = task['commitmentId'];
      if (detailId is! String ||
          detailId.trim().isEmpty ||
          commitmentId is! String ||
          existingDetailIds.contains(detailId)) {
        continue;
      }

      existingDetailIds.add(detailId);
      synthesizedDetails.add(
        _normalizeRestoreRow('CommitmentDetailTable', {
          'id': detailId,
          'createdBy': task['createdBy'],
          'dateCreated': task['dateCreated'],
          'dateUpdated': task['dateUpdated'],
          'lastModifiedBy': task['lastModifiedBy'],
          'amount': task['amount'] ?? 0.0,
          'description': task['name'] ?? 'Restored commitment detail',
          'type': 4,
          'taskType': task['type'] ?? 0,
          'savingId': task['sourceSavingId'],
          'targetSavingId': task['targetSavingId'],
          'payeeId': task['payeeId'],
          'commitmentId': commitmentId,
        }, detailRows.length + synthesizedDetails.length),
      );
    }

    if (synthesizedDetails.isNotEmpty) {
      normalized['CommitmentDetailTable'] = [
        ...detailRows,
        ...synthesizedDetails,
      ];
    }
  }

  Map<String, dynamic> _normalizeRestoreRow(
    String tableName,
    Map<String, dynamic> row,
    int index,
  ) {
    final now = DateTime.now().toIso8601String();

    row.putIfAbsent('id', () => UuidGenerator().v4());
    row.putIfAbsent('createdBy', () => 'restore');
    row.putIfAbsent('dateCreated', () => now);
    row.putIfAbsent('dateUpdated', () => row['dateCreated'] ?? now);
    row.putIfAbsent('lastModifiedBy', () => row['createdBy'] ?? 'restore');

    switch (tableName) {
      case 'MoneyStorageTable':
        row.putIfAbsent('iconUrl', () => '');
        row.putIfAbsent('type', () => 'General');
        row.putIfAbsent('displayOrder', () => index);
        break;
      case 'SavingTable':
        row.putIfAbsent('currency', () => 'MYR');
        row.putIfAbsent('isPublic', () => false);
        row.putIfAbsent('isHasGoal', () => false);
        row.putIfAbsent('goal', () => 0.0);
        row.putIfAbsent('isHasStartDate', () => false);
        row.putIfAbsent('startDate', () => null);
        row.putIfAbsent('isHasEndDate', () => false);
        row.putIfAbsent('endDate', () => null);
        row.putIfAbsent('isSaveDaily', () => false);
        row.putIfAbsent('isSaveWeekly', () => false);
        row.putIfAbsent('isSaveMonthly', () => false);
        row.putIfAbsent('type', () => 'SAVING');
        row.putIfAbsent('currentAmount', () => 0.0);
        row.putIfAbsent('displayOrder', () => index);
        break;
      case 'TransactionTable':
        row.putIfAbsent('description', () => '');
        row.putIfAbsent('loanId', () => null);
        row.putIfAbsent('lendingId', () => null);
        break;
      case 'CategoryTable':
        row.putIfAbsent('iconFontFamily', () => 'MaterialIcons');
        row.putIfAbsent('orderIndex', () => index);
        row.putIfAbsent('isActive', () => true);
        row.putIfAbsent('createdAt', () => row['dateCreated'] ?? now);
        break;
      case 'CommitmentDetailTable':
        row.putIfAbsent('taskType', () => 0);
        row.putIfAbsent('linkedCreditCardId', () => null);
        row.putIfAbsent('eppTotalInstallments', () => null);
        row.putIfAbsent('eppCompletedInstallments', () => 0);
        break;
      case 'CommitmentTaskTable':
        row.putIfAbsent('isDone', () => false);
        row.putIfAbsent('type', () => row['isThirdParty'] == true ? 1 : 0);
        row.putIfAbsent('sourceSavingId', () => row['savingId']);
        row.putIfAbsent('targetSavingId', () => null);
        row.putIfAbsent('payeeId', () => null);
        row.putIfAbsent('note', () => null);
        row.putIfAbsent('paymentReference', () => null);
        row.putIfAbsent('transactionId', () => null);
        break;
      case 'CreditCardChargeTable':
        row.putIfAbsent('reservedSavingId', () => null);
        row.putIfAbsent('status', () => 'posted');
        row.putIfAbsent('isRebate', () => false);
        break;
      case 'CreditCardChargePaymentTable':
        row.putIfAbsent('deductedSavingId', () => null);
        break;
      case 'LoanTable':
        row.putIfAbsent('status', () => 'active');
        row.putIfAbsent('noAutoDeduct', () => false);
        break;
      case 'LendingTable':
        row.putIfAbsent('status', () => 'active');
        row.putIfAbsent('noAutoDeduct', () => false);
        break;
      case 'CreditCardTable':
        row.putIfAbsent('cardType', () => 'credit_card');
        row.putIfAbsent('providerName', () => null);
        break;
      case 'SavingsPlanTable':
        row.putIfAbsent('currentAmount', () => 0.0);
        row.putIfAbsent('currency', () => 'MYR');
        row.putIfAbsent('status', () => 'active');
        row.putIfAbsent('createdAt', () => row['dateCreated'] ?? now);
        break;
      case 'SavingsPlanItemTable':
        row.putIfAbsent('sortOrder', () => (index + 1) * 1000.0);
        row.putIfAbsent('totalCost', () => 0.0);
        row.putIfAbsent('depositPaid', () => 0.0);
        row.putIfAbsent('amountPaid', () => 0.0);
        row.putIfAbsent('isCompleted', () => false);
        break;
      case 'FileStorageTable':
        row.putIfAbsent('category', () => 'document');
        row.putIfAbsent('status', () => 'active');
        row.putIfAbsent('isBackedUp', () => false);
        break;
    }

    return row;
  }

  /// Restores data directly from [filePath] without opening a file picker.
  ///
  /// [type] must be either `'.json'` or `'.sqlite'`.
  /// Returns `true` on success, throws on error.
  Future<bool> restoreFromPath(final String filePath, final String type) async {
    final isJson = type != '.sqlite';
    final ext = isJson ? 'json' : 'sqlite';

    final File file = File(filePath);

    if (!file.existsSync()) {
      throw Exception('Backup file not found: $filePath');
    }

    final List<String> allowedExtensions = [ext];
    if (!FileUtil.isMatchCustomExtensions(
      file: file,
      allowedExtensions: allowedExtensions,
    )) {
      throw 'The file extension is ${FileUtil.getFileExtension(file)}, '
          'it must be ${allowedExtensions.join(" or ")}';
    }

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
  }
}
