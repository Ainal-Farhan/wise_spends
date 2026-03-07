import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/recurring_transaction_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Recurring Transaction Repository Interface
abstract class IRecurringTransactionRepository
    extends
        ICrudRepository<
          RecurringTransactionTable,
          $RecurringTransactionTableTable,
          RecurringTransactionTableCompanion,
          RecurringTransaction
        > {
  IRecurringTransactionRepository(AppDatabase db)
    : super(db, db.recurringTransactionTable);

  /// Watch all recurring transactions
  Stream<List<RecurringTransaction>> watchAll();

  /// Get all recurring transactions
  Future<List<RecurringTransaction>> getAll();

  /// Watch recurring transactions by saving account
  Stream<List<RecurringTransaction>> watchBySavingId(String savingId);
}
