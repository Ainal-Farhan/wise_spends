import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

abstract class ITransactionRepository
    extends
        ICrudRepository<
          TransactionTable,
          $TransactionTableTable,
          TransactionTableCompanion,
          TrnsctnTransaction
        > {
  ITransactionRepository(AppDatabase db) : super(db, db.transactionTable);

  // ---------------------------------------------------------------------------
  // Delete helpers
  // ---------------------------------------------------------------------------

  /// Deletes all transactions linked to a savings account.
  /// Called when the account itself is deleted.
  Future<void> deleteAllBySavingAccount(String savingAccountId);

  // ---------------------------------------------------------------------------
  // Fetch — all / recent
  // ---------------------------------------------------------------------------

  /// Returns every transaction, unfiltered.
  Future<List<TransactionEntity>> fetchAll();

  /// Returns the [limit] most recent transactions ordered by date descending.
  Future<List<TransactionEntity>> fetchRecent({int limit = 10});

  // ---------------------------------------------------------------------------
  // Fetch — filtered
  // ---------------------------------------------------------------------------

  /// Returns transactions whose date falls within [from] – [to] inclusive.
  Future<List<TransactionEntity>> fetchByDateRange({
    required DateTime from,
    required DateTime to,
  });

  /// Returns transactions of the given [type] (income / expense / transfer).
  Future<List<TransactionEntity>> fetchByType(TransactionType type);

  /// Returns transactions linked to the given [categoryId].
  Future<List<TransactionEntity>> fetchByCategory(String categoryId);

  // ---------------------------------------------------------------------------
  // Fetch — single
  // ---------------------------------------------------------------------------

  /// Returns the transaction with the given [transactionId], or null.
  Future<TransactionEntity?> fetchById(String transactionId);

  // ---------------------------------------------------------------------------
  // Aggregates
  // ---------------------------------------------------------------------------

  /// Total income amount within [from] – [to].
  Future<double> sumIncome({required DateTime from, required DateTime to});

  /// Total expense amount within [from] – [to].
  Future<double> sumExpenses({required DateTime from, required DateTime to});

  // ---------------------------------------------------------------------------
  // Mutate
  // ---------------------------------------------------------------------------

  /// Inserts a new transaction record and returns the saved entity.
  Future<TransactionEntity> saveTransaction(TransactionEntity transaction);

  /// Updates an existing transaction record and returns the updated entity.
  Future<TransactionEntity> editTransaction(TransactionEntity transaction);

  /// Permanently deletes the transaction identified by [transactionId].
  Future<void> removeTransaction(String transactionId);

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  /// Returns transactions whose description or note contains [keyword].
  Future<List<TransactionEntity>> searchByKeyword(String keyword);
}
