import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/transaction/i_transaction_tag_map_repository.dart';

/// Transaction Tag Map Repository Implementation
class TransactionTagMapRepository extends ITransactionTagMapRepository {
  TransactionTagMapRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'TransactionTagMapTable';

  @override
  Stream<List<TransactionTagMap>> watchByTransactionId(String transactionId) {
    return (db.select(
      db.transactionTagMapTable,
    )..where((tbl) => tbl.transactionId.equals(transactionId))).watch();
  }

  @override
  Future<void> deleteByTransactionId(String transactionId) async {
    await (db.delete(
      db.transactionTagMapTable,
    )..where((tbl) => tbl.transactionId.equals(transactionId))).go();
  }

  @override
  TransactionTagMap fromJson(Map<String, dynamic> json) =>
      TransactionTagMap.fromJson(json);
}
