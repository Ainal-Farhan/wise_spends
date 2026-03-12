import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/transaction/transaction_tag_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Transaction Tag Repository Interface
abstract class ITransactionTagRepository
    extends
        ICrudRepository<
          TransactionTagTable,
          $TransactionTagTableTable,
          TransactionTagTableCompanion,
          TransactionTag
        > {
  ITransactionTagRepository(AppDatabase db) : super(db, db.transactionTagTable);

  /// Watch all tags
  Stream<List<TransactionTag>> watchAll();

  /// Get all tags
  Future<List<TransactionTag>> getAll();
}
