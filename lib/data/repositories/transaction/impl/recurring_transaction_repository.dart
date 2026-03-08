import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/transaction/i_recurring_transaction_repository.dart';

/// Recurring Transaction Repository Implementation
class RecurringTransactionRepository extends IRecurringTransactionRepository {
  RecurringTransactionRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'RecurringTransactionTable';

  @override
  Stream<List<RecurringTransaction>> watchAll() {
    return db.select(db.recurringTransactionTable).watch();
  }

  @override
  Future<List<RecurringTransaction>> getAll() async {
    return db.select(db.recurringTransactionTable).get();
  }

  @override
  Stream<List<RecurringTransaction>> watchBySavingId(String savingId) {
    return (db.select(
      db.recurringTransactionTable,
    )..where((tbl) => tbl.savingId.equals(savingId))).watch();
  }

  @override
  RecurringTransaction fromJson(Map<String, dynamic> json) =>
      RecurringTransaction.fromJson(json);
}
