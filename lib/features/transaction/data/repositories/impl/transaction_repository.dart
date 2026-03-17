import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/features/transaction/data/repositories/i_transaction_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
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
  // Ordering — shared helper
  // ---------------------------------------------------------------------------

  /// Standard sort applied to every fetch:
  ///   1. transactionDateTime DESC — NULL rows sort first (newest-feeling)
  ///   2. dateCreated DESC         — stable tiebreaker when datetime is equal
  ///                                 or both are null
  ///
  /// The lambda type must match the Drift-generated table class
  /// [$TransactionTableTable], not the companion/table-definition [TransactionTable].
  List<OrderingTerm Function($TransactionTableTable)> get _defaultOrder => [
    (tbl) => OrderingTerm(
      expression: tbl.transactionDateTime,
      mode: OrderingMode.desc,
      nulls: NullsOrder.first,
    ),
    (tbl) => OrderingTerm.desc(tbl.dateCreated),
  ];

  // ---------------------------------------------------------------------------
  // Fetch — all / recent
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> fetchAll() async {
    final query = db.select(db.transactionTable).join([
      leftOuterJoin(
        db.categoryTable,
        db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
      ),
    ])..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList());

    final rows = await query.get();
    return rows.map((row) => _mapToEntityWithCategory(row)).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchRecent({int limit = 10}) async {
    final query =
        db.select(db.transactionTable).join([
            leftOuterJoin(
              db.categoryTable,
              db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
            ),
          ])
          ..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList())
          ..limit(limit);

    final rows = await query.get();
    return rows.map((row) => _mapToEntityWithCategory(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch — filtered
  // ---------------------------------------------------------------------------

  @override
  Future<List<TransactionEntity>> fetchByDateRange({
    required DateTime from,
    required DateTime to,
  }) async {
    final query =
        db.select(db.transactionTable).join([
            leftOuterJoin(
              db.categoryTable,
              db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
            ),
          ])
          ..where(
            // Filter on transactionDateTime when present, fall back to
            // dateCreated for rows where the user didn't set a date.
            (db.transactionTable.transactionDateTime.isBiggerOrEqualValue(
                          from,
                        ) |
                        db.transactionTable.transactionDateTime.isNull()) &
                    (db.transactionTable.transactionDateTime
                            .isSmallerOrEqualValue(to) |
                        db.transactionTable.transactionDateTime.isNull()) |
                (db.transactionTable.transactionDateTime.isNull() &
                    db.transactionTable.dateCreated.isBiggerOrEqualValue(from) &
                    db.transactionTable.dateCreated.isSmallerOrEqualValue(to)),
          )
          ..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList());

    final rows = await query.get();
    return rows.map((row) => _mapToEntityWithCategory(row)).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchByType(TransactionType type) async {
    final query =
        db.select(db.transactionTable).join([
            leftOuterJoin(
              db.categoryTable,
              db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
            ),
          ])
          ..where(db.transactionTable.type.equals(type.name))
          ..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList());

    final rows = await query.get();
    return rows.map((row) => _mapToEntityWithCategory(row)).toList();
  }

  @override
  Future<List<TransactionEntity>> fetchByCategory(String categoryId) async {
    final query =
        db.select(db.transactionTable).join([
            leftOuterJoin(
              db.categoryTable,
              db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
            ),
          ])
          ..where(db.transactionTable.categoryId.equals(categoryId))
          ..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList());

    final rows = await query.get();
    return rows.map((row) => _mapToEntityWithCategory(row)).toList();
  }

  // ---------------------------------------------------------------------------
  // Fetch — single
  // ---------------------------------------------------------------------------

  @override
  Future<TransactionEntity?> fetchById(String transactionId) async {
    final query =
        db.select(db.transactionTable).join([
            leftOuterJoin(
              db.categoryTable,
              db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
            ),
          ])
          ..where(db.transactionTable.id.equals(transactionId))
          ..limit(1);

    final rows = await query.get();
    if (rows.isEmpty) return null;
    return _mapToEntityWithCategory(rows.first);
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
    return rows.fold<double>(0.0, (sum, row) => sum + row.amount);
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
    return rows.fold<double>(0.0, (sum, row) => sum + row.amount);
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
    final lower = keyword.toLowerCase();
    final query = db.select(db.transactionTable).join([
      leftOuterJoin(
        db.categoryTable,
        db.categoryTable.id.equalsExp(db.transactionTable.categoryId),
      ),
    ])..orderBy(_defaultOrder.map((e) => e(db.transactionTable)).toList());

    final rows = await query.get();
    return rows
        .where((row) {
          final transaction = row.readTable(db.transactionTable);
          return transaction.description.toLowerCase().contains(lower) ||
              (transaction.note?.toLowerCase().contains(lower) ?? false);
        })
        .map((row) => _mapToEntityWithCategory(row))
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Private mapper
  // ---------------------------------------------------------------------------

  TransactionEntity _mapToEntityWithCategory(dynamic row) {
    final transaction = row.readTable(db.transactionTable);
    final categoryRow = row.readTableOrNull(db.categoryTable);

    CategoryEntity? category;
    if (categoryRow != null) {
      category = CategoryEntity(
        id: categoryRow.id,
        name: categoryRow.name,
        iconCodePoint: categoryRow.iconCodePoint,
        iconFontFamily: categoryRow.iconFontFamily,
        isIncome: categoryRow.isIncome,
        isExpense: categoryRow.isExpense,
        orderIndex: categoryRow.orderIndex,
        isActive: categoryRow.isActive,
        createdAt: categoryRow.createdAt,
      );
    }

    return TransactionEntity(
      id: transaction.id,
      title: transaction.description,
      amount: transaction.amount,
      type: transaction.type,
      savingId: transaction.savingId,
      destinationSavingId: transaction.destinationSavingId,
      categoryId: transaction.categoryId,
      category: category,
      commitmentTaskId: transaction.commitmentTaskId,
      payeeId: transaction.payeeId,
      date: transaction.transactionDateTime ?? transaction.dateCreated,
      note: transaction.note,
      createdAt: transaction.dateCreated,
      updatedAt: transaction.dateUpdated,
    );
  }

  @override
  TrnsctnTransaction fromJson(Map<String, dynamic> json) =>
      TrnsctnTransaction.fromJson(json);
}
