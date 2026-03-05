import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Transaction repository interface - defines contract for data layer
abstract class ITransactionRepository {
  /// Get all transactions
  Future<List<TransactionEntity>> getAllTransactions();

  /// Get transactions by date range
  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get transactions by type
  Future<List<TransactionEntity>> getTransactionsByType(
    TransactionType type,
  );

  /// Get transactions by category
  Future<List<TransactionEntity>> getTransactionsByCategory(
    String categoryId,
  );

  /// Get a single transaction by ID
  Future<TransactionEntity?> getTransactionById(String id);

  /// Get recent transactions (limited)
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10});

  /// Get total income for a date range
  Future<double> getTotalIncome({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get total expenses for a date range
  Future<double> getTotalExpenses({
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Create a new transaction
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  /// Update an existing transaction
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Delete a transaction
  Future<void> deleteTransaction(String id);

  /// Delete transactions by category
  Future<void> deleteTransactionsByCategory(String categoryId);

  /// Search transactions by title/note
  Future<List<TransactionEntity>> searchTransactions(String query);

  /// Get transactions grouped by date for display
  Future<Map<DateTime, List<TransactionEntity>>> getTransactionsGroupedByDate({
    DateTime? startDate,
    DateTime? endDate,
  });
}
