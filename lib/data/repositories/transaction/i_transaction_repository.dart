import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Enhanced Transaction Repository Interface
/// Extends the base CRUD interface with transaction-specific methods
abstract class ITransactionRepository extends ICrudRepository<TransactionTable,
    $TransactionTableTable, TransactionTableCompanion, TrnsctnTransaction> {
  ITransactionRepository(AppDatabase db) : super(db, db.transactionTable);

  Future<void> deleteBasedOnSavingId(String savingId);

  // Enhanced methods for BLoC support
  Future<List<TransactionEntity>> getAllTransactions();
  Future<List<TransactionEntity>> getTransactionsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<List<TransactionEntity>> getTransactionsByType(
    TransactionType type,
  );
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId);
  Future<TransactionEntity?> getTransactionById(String id);
  Future<List<TransactionEntity>> getRecentTransactions({int limit = 10});
  Future<double> getTotalIncome({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<double> getTotalExpenses({
    required DateTime startDate,
    required DateTime endDate,
  });
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionEntity>> searchTransactions(String query);
}
