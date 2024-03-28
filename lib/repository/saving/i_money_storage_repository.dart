import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class IMoneyStorageRepository extends ICrudRepository<
    $MoneyStorageTableTable, MoneyStorageTableCompanion, SvngMoneyStorage> {
  IMoneyStorageRepository(AppDatabase db) : super(db, db.moneyStorageTable);

  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(final String userId);

  Stream<SvngMoneyStorage> watchBasedOnMoneyStorageId(
      final String moneyStorageId);

  Future<void> updatePart({
    required final MoneyStorageTableCompanion moneyStorageTableCompanion,
    required final String moneyStorageId,
  });
}
