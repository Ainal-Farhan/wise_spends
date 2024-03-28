import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/composite/saving_with_money_storage.dart';
import 'package:wise_spends/db/domain/saving/saving_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ISavingRepository extends ICrudRepository<SavingTable,
    $SavingTableTable, SavingTableCompanion, SvngSaving> {
  ISavingRepository(AppDatabase db) : super(db, db.savingTable);

  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId);

  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(
      final String moneyStorageId);

  Stream<List<SavingWithMoneyStorage>>
      watchSavingListWithMoneyStorageBasedOnUserId(String userId);
}
