import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
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
      ..where((tbl) => tbl.isExpense.equals(_isExpenseType(type)));

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
            tbl.isExpense.equals(false) &
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
            tbl.isExpense.equals(true) &
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
    // Extract hour and minute from time if available
    int? hour;
    int? minute;
    if (transaction.time != null) {
      hour = transaction.time!.hour;
      minute = transaction.time!.minute;
    }

    final companion = TransactionTableCompanion.insert(
      id: Value(transaction.id),
      type: transaction.type,
      description: Value(transaction.title),
      amount: transaction.amount,
      savingId: transaction.sourceAccountId ?? '',
      isExpense: Value(transaction.type == TransactionType.expense),
      expenseId: Value(transaction.categoryId),
      transactionHour: Value(hour),
      transactionMinute: Value(minute),
      note: Value(transaction.note),
      destinationAccountId: Value(transaction.destinationAccountId),
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
    // Extract hour and minute from time if available
    int? hour;
    int? minute;
    if (transaction.time != null) {
      hour = transaction.time!.hour;
      minute = transaction.time!.minute;
    }

    final companion = TransactionTableCompanion(
      type: Value(transaction.type),
      description: Value(transaction.title),
      amount: Value(transaction.amount),
      savingId: Value(transaction.sourceAccountId ?? ''),
      isExpense: Value(transaction.type == TransactionType.expense),
      expenseId: Value(transaction.categoryId),
      transactionHour: Value(hour),
      transactionMinute: Value(minute),
      note: Value(transaction.note),
      destinationAccountId: Value(transaction.destinationAccountId),
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
    // Reconstruct TimeOfDay from hour and minute columns
    TimeOfDay? time;
    if (row.transactionHour != null && row.transactionMinute != null) {
      time = TimeOfDay(
        hour: row.transactionHour!,
        minute: row.transactionMinute!,
      );
    }

    return TransactionEntity(
      id: row.id,
      title: row.description,
      amount: row.amount,
      type: row.type,
      categoryId: row.expenseId ?? 'uncategorized',
      categoryName: null, // Would need join with expense table
      categoryIcon: null,
      date: row.dateCreated,
      time: time,
      note: row.note,
      sourceAccountId: row.savingId,
      destinationAccountId: row.destinationAccountId,
      createdAt: row.dateCreated,
      updatedAt: row.dateUpdated,
    );
  }

  /// Helper method to convert TransactionType to isExpense boolean
  bool _isExpenseType(TransactionType type) {
    switch (type) {
      case TransactionType.expense:
        return true;
      case TransactionType.income:
        return false;
      case TransactionType.transfer:
        return false;
    }
  }
}
