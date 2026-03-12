import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_tag_map_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Transaction Tag Map Repository Interface
abstract class ITransactionTagMapRepository
    extends
        ICrudRepository<
          TransactionTagMapTable,
          $TransactionTagMapTableTable,
          TransactionTagMapTableCompanion,
          TransactionTagMap
        > {
  ITransactionTagMapRepository(AppDatabase db)
    : super(db, db.transactionTagMapTable);

  /// Watch all tag maps for a transaction
  Stream<List<TransactionTagMap>> watchByTransactionId(String transactionId);

  /// Delete all tag maps for a transaction
  Future<void> deleteByTransactionId(String transactionId);
}
