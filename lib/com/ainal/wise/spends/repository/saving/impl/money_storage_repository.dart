import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/saving/i_money_storage_repository.dart';

class MoneyStorageRepository extends IMoneyStorageRepository {
  MoneyStorageRepository() : super(AppDatabase());

  @override
  Future<void> updatePart({
    required MoneyStorageTableCompanion moneyStorageTableCompanion,
    required String moneyStorageId,
  }) async {
    await (db.update(db.moneyStorageTable)
          ..where((tbl) => tbl.id.equals(moneyStorageId)))
        .write(moneyStorageTableCompanion);
  }

  @override
  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(String userId) {
    return (db.select(db.moneyStorageTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }
}