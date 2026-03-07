import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_repository.dart';

/// Transaction Tag Repository Implementation
class TransactionTagRepository extends ITransactionTagRepository {
  TransactionTagRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'TransactionTagTable';

  @override
  Stream<List<TransactionTag>> watchAll() {
    return db.select(db.transactionTagTable).watch();
  }

  @override
  Future<List<TransactionTag>> getAll() async {
    return db.select(db.transactionTagTable).get();
  }
}
