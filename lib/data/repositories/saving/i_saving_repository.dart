import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/composite/saving_with_money_storage.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ISavingRepository extends ICrudRepository<SavingTable,
    $SavingTableTable, SavingTableCompanion, SvngSaving> {
  ISavingRepository(AppDatabase db) : super(db, db.savingTable);

  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId);

  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(
      final String moneyStorageId);

  Stream<List<SavingWithMoneyStorage>>
      watchSavingListWithMoneyStorageBasedOnUserId(String userId);
}
