import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/saving/money_storage_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';

abstract class IMoneyStorageRepository
    extends
        ICrudRepository<
          MoneyStorageTable,
          $MoneyStorageTableTable,
          MoneyStorageTableCompanion,
          SvngMoneyStorage
        > {
  IMoneyStorageRepository(AppDatabase db) : super(db, db.moneyStorageTable);

  Stream<List<SvngMoneyStorage>> watchBasedOnUserId(final String userId);

  Future<List<MoneyStorageVO>> getMoneyStorageList();

  Future<MoneyStorageVO?> getMoneyStorageById(String id);

  Future<void> addMoneyStorage(
    String shortName,
    String longName,
    double amount,
  );
  Future<void> updateMoneyStorage(
    String id,
    String shortName,
    String longName,
    double amount,
  );
  Future<void> deleteMoneyStorage(String id);
}
