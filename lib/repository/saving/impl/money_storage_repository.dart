import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/saving/i_money_storage_repository.dart';

class MoneyStorageRepository extends IMoneyStorageRepository {
  MoneyStorageRepository() : super(AppDatabase());

  @override
  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(String userId) {
    return (db.select(db.moneyStorageTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }

  @override
  String getTypeName() => 'MoneyStorageTable';
}
