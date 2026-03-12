import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/widget/presentation/services/widget_service.dart';

class TransactionRepository extends ITransactionRepository {
  TransactionRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'TransactionTable';

  // ---------------------------------------------------------------------------
  // Delete helpers
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteAllBySavingAccount(String savingAccountId) async {
    await (db.delete(
      db.transactionTable,
    )..where((tbl) => tbl.savingId.equals(savingAccountId))).go();
  }

  // ---------------------------------------------------------------------------
  // Fetch — all / recent
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> fetchAll() async {
    final rows = await db.select(db.transactionTable).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchRecent({int limit = 10}) async {
    final rows =
        await (db.select(db.transactionTable)
              ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateCreated)])
              ..limit(limit))
            .get();
    return rows.map(_toEntity).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch — filtered
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> fetchByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows =
        await (db.select(db.transactionTable)..where(
              (tbl) =>
                  tbl.dateCreated.isBiggerOrEqualValue(from) &
                  tbl.dateCreated.isSmallerOrEqualValue(to),
            ))
            .get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchByType(TransactionType type) async {
    final rows = await (db.select(
      db.transactionTable,
    )..where((tbl) => tbl.type.equals(type.name))).get();
    return rows.map(_toEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchByCategory(String categoryId) async {
    final rows = await (db.select(
      db.transactionTable,
    )..where((tbl) => tbl.categoryId.equals(categoryId))).get();
    return rows.map(_toEntity).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch — single
  // ---------------------------------------------------------------------------

  @override
  Future<TransactionEntity?> fetchById(String transactionId) async {
    final rows = await (db.select(
      db.transactionTable,
    )..where((tbl) => tbl.id.equals(transactionId))).get();
    if (rows.isEmpty) return null;
    return _toEntity(rows.first);
  }

  // ---------------------------------------------------------------------------
  // Aggregates
  // ---------------------------------------------------------------------------

  @override
  Future<double> sumIncome({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows =
        await (db.select(db.transactionTable)..where(
              (tbl) =>
                  tbl.type.equals(TransactionType.income.name) &
                  tbl.dateCreated.isBiggerOrEqualValue(from) &
                  tbl.dateCreated.isSmallerOrEqualValue(to),
            ))
            .get();
    return rows.fold(0.0, (sum, row) async => await sum + row.amount);
  }

  @override
  Future<double> sumExpenses({
    required DateTime from,
    required DateTime to,
  }) async {
    final rows =
        await (db.select(db.transactionTable)..where(
              (tbl) =>
                  tbl.type.equals(TransactionType.expense.name) &
                  tbl.dateCreated.isBiggerOrEqualValue(from) &
                  tbl.dateCreated.isSmallerOrEqualValue(to),
            ))
            .get();
    return rows.fold(0.0, (sum, row) async => await sum + row.amount);
  }

  // ---------------------------------------------------------------------------
  // Mutate
  // ---------------------------------------------------------------------------

  @override
  Future<TransactionEntity> saveTransaction(
    TransactionEntity transaction,
  ) async {
    final companion = TransactionTableCompanion.insert(
      id: Value(transaction.id),
      type: transaction.type,
      description: Value(transaction.title),
      amount: transaction.amount,
      savingId: transaction.savingId,
      destinationSavingId: Value(transaction.destinationSavingId),
      categoryId: Value(transaction.categoryId),
      commitmentTaskId: Value(transaction.commitmentTaskId),
      payeeId: Value(transaction.payeeId),
      transactionDateTime: Value(transaction.date),
      note: Value(transaction.note),
      createdBy: 'system',
      dateCreated: Value(transaction.createdAt),
      dateUpdated: transaction.updatedAt,
      lastModifiedBy: 'system',
    );

    await db.into(db.transactionTable).insert(companion);

    await WidgetService.updateLastTransaction(transaction);
    return transaction;
  }

  @override
  Future<TransactionEntity> editTransaction(
    TransactionEntity transaction,
  ) async {
    final companion = TransactionTableCompanion(
      type: Value(transaction.type),
      description: Value(transaction.title),
      amount: Value(transaction.amount),
      savingId: Value(transaction.savingId),
      destinationSavingId: Value(transaction.destinationSavingId),
      categoryId: Value(transaction.categoryId),
      commitmentTaskId: Value(transaction.commitmentTaskId),
      payeeId: Value(transaction.payeeId),
      transactionDateTime: Value(transaction.date),
      note: Value(transaction.note),
      dateUpdated: Value(transaction.updatedAt),
      lastModifiedBy: const Value('system'),
    );

    await (db.update(
      db.transactionTable,
    )..where((tbl) => tbl.id.equals(transaction.id))).write(companion);

    await WidgetService.updateLastTransaction(transaction);

    return transaction;
  }

  @override
  Future<void> removeTransaction(String transactionId) async {
    await (db.delete(
      db.transactionTable,
    )..where((tbl) => tbl.id.equals(transactionId))).go();
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> searchByKeyword(String keyword) async {
    final rows = await db.select(db.transactionTable).get();
    final lower = keyword.toLowerCase();
    return rows
        .where(
          (row) =>
              row.description.toLowerCase().contains(lower) ||
              (row.note?.toLowerCase().contains(lower) ?? false),
        )
        .map(_toEntity)
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Private mapper
  // ---------------------------------------------------------------------------

  TransactionEntity _toEntity(TrnsctnTransaction row) {
    return TransactionEntity(
      id: row.id,
      title: row.description,
      amount: row.amount,
      type: row.type,
      savingId: row.savingId,
      destinationSavingId: row.destinationSavingId,
      categoryId: row.categoryId,
      commitmentTaskId: row.commitmentTaskId,
      payeeId: row.payeeId,
      date: row.transactionDateTime ?? row.dateCreated,
      note: row.note,
      createdAt: row.dateCreated,
      updatedAt: row.dateUpdated,
    );
  }

  @override
  TrnsctnTransaction fromJson(Map<String, dynamic> json) =>
      TrnsctnTransaction.fromJson(json);
}
