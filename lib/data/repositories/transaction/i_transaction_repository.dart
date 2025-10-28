import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ITransactionRepository extends ICrudRepository<TransactionTable,
    $TransactionTableTable, TransactionTableCompanion, TrnsctnTransaction> {
  ITransactionRepository(AppDatabase db) : super(db, db.transactionTable);

  Future<void> deleteBasedOnSavingId(String savingId);
}
