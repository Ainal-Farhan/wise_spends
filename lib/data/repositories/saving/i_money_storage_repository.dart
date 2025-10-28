import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/saving/money_storage_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class IMoneyStorageRepository extends ICrudRepository<
    MoneyStorageTable,
    $MoneyStorageTableTable,
    MoneyStorageTableCompanion,
    SvngMoneyStorage> {
  IMoneyStorageRepository(AppDatabase db) : super(db, db.moneyStorageTable);

  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(final String userId);
}
