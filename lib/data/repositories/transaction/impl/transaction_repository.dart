import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Transaction Repository Implementation
/// Handles all database operations for transactions
class TransactionRepository extends ITransactionRepository {
  TransactionRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'TransactionTable';

  @override
  Future<void> deleteBasedOnSavingId(String savingId) async {
    await (db.delete(
      db.transactionTable,
    )..where((tbl) => tbl.savingId.equals(savingId))).go();
  }

  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    final query = db.select(db.transactionTable);
    final rows = await query.get();

    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = db.select(db.transactionTable)
      ..where(
        (tbl) =>
            tbl.dateCreated.isBiggerOrEqualValue(startDate) &
            tbl.dateCreated.isSmallerOrEqualValue(endDate),
      );

    final rows = await query.get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType(
    TransactionType type,
  ) async {
    final query = db.select(db.transactionTable)
      ..where((tbl) => tbl.type.equals(type.name));

    final rows = await query.get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(
    String categoryId,
  ) async {
    // Note: Current schema doesn't have categoryId, would need schema update
    // For now, return empty list or implement based on expenseId mapping
    final query = db.select(db.transactionTable)
      ..where((tbl) => tbl.expenseId.equals(categoryId));

    final rows = await query.get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<TransactionEntity?> getTransactionById(String id) async {
    final query = db.select(db.transactionTable)
      ..where((tbl) => tbl.id.equals(id));

    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapToEntity(rows.first);
  }

  @override
  Future<List<TransactionEntity>> getRecentTransactions({
    int limit = 10,
  }) async {
    final query = db.select(db.transactionTable)
      ..orderBy([(tbl) => OrderingTerm.desc(tbl.dateCreated)])
      ..limit(limit);

    final rows = await query.get();
    return rows.map(_mapToEntity).toList();
  }

  @override
  Future<double> getTotalIncome({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = db.select(db.transactionTable)
      ..where(
        (tbl) =>
            tbl.type.equals(TransactionType.income.name) &
            tbl.dateCreated.isBiggerOrEqualValue(startDate) &
            tbl.dateCreated.isSmallerOrEqualValue(endDate),
      );

    final rows = await query.get();
    return rows.fold<double>(0.0, (sum, row) => sum + row.amount);
  }

  @override
  Future<double> getTotalExpenses({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final query = db.select(db.transactionTable)
      ..where(
        (tbl) =>
            tbl.type.equals(TransactionType.expense.name) &
            tbl.dateCreated.isBiggerOrEqualValue(startDate) &
            tbl.dateCreated.isSmallerOrEqualValue(endDate),
      );

    final rows = await query.get();
    return rows.fold<double>(0.0, (sum, row) => sum + row.amount);
  }

  @override
  Future<TransactionEntity> createTransaction(
    TransactionEntity transaction,
  ) async {
    final companion = TransactionTableCompanion.insert(
      id: Value(transaction.id),
      type: transaction.type,
      description: Value(transaction.title),
      amount: transaction.amount,
      savingId: transaction.sourceAccountId ?? '',
      expenseId: Value(transaction.categoryId),
      transactionDateTime: Value(transaction.date),
      note: Value(transaction.note),
      createdBy: 'system',
      dateCreated: Value(transaction.createdAt),
      dateUpdated: transaction.updatedAt,
      lastModifiedBy: 'system',
    );

    await db.into(db.transactionTable).insert(companion);
    return transaction;
  }

  @override
  Future<TransactionEntity> updateTransaction(
    TransactionEntity transaction,
  ) async {
    final companion = TransactionTableCompanion(
      type: Value(transaction.type),
      description: Value(transaction.title),
      amount: Value(transaction.amount),
      savingId: Value(transaction.sourceAccountId ?? ''),
      expenseId: Value(transaction.categoryId),
      transactionDateTime: Value(transaction.date),
      note: Value(transaction.note),
      dateUpdated: Value(transaction.updatedAt),
      lastModifiedBy: const Value('system'),
    );

    await (db.update(
      db.transactionTable,
    )..where((tbl) => tbl.id.equals(transaction.id))).write(companion);

    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await (db.delete(
      db.transactionTable,
    )..where((tbl) => tbl.id.equals(id))).go();
  }

  @override
  Future<List<TransactionEntity>> searchTransactions(String query) async {
    final results = await db.select(db.transactionTable).get();

    return results
        .where(
          (row) =>
              row.description.toLowerCase().contains(query.toLowerCase()) ||
              (row.expenseId?.toLowerCase().contains(query.toLowerCase()) ??
                  false),
        )
        .map(_mapToEntity)
        .toList();
  }

  /// Helper method to map database row to domain entity
  TransactionEntity _mapToEntity(TrnsctnTransaction row) {
    return TransactionEntity(
      id: row.id,
      title: row.description,
      amount: row.amount,
      type: row.type,
      categoryId: row.expenseId ?? 'uncategorized',
      date: row.transactionDateTime ?? row.dateCreated,
      note: row.note,
      sourceAccountId: row.savingId,
      createdAt: row.dateCreated,
      updatedAt: row.dateUpdated,
    );
  }
}
