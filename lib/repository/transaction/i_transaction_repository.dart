import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/transaction/transaction_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ITransactionRepository extends ICrudRepository<TransactionTable,
    $TransactionTableTable, TransactionTableCompanion, TrnsctnTransaction> {
  ITransactionRepository(AppDatabase db) : super(db, db.transactionTable);

  Future<void> deleteBasedOnSavingId(String savingId);
}
