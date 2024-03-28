import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/transaction/i_transaction_repository.dart';

class TransactionRepository extends ITransactionRepository {
  TransactionRepository() : super(AppDatabase());

  @override
  Future<void> deleteBasedOnSavingId(String savingId) async {
    await (db.delete(db.transactionTable)
          ..where((tbl) => tbl.savingId.equals(savingId)))
        .go();
  }
}
