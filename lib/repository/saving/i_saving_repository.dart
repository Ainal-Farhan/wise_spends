import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/composite/saving_with_money_storage.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class ISavingRepository extends ICrudRepository<$SavingTableTable,
    SavingTableCompanion, SvngSaving> {
  ISavingRepository(AppDatabase db) : super(db, db.savingTable);

  Stream<SvngSaving> watchBasedOnSavingId(final String savingId);

  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId);

  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(
      final String moneyStorageId);

  Stream<List<SavingWithMoneyStorage>>
      watchSavingListWithMoneyStorageBasedOnUserId(String userId);

  Future<void> updatePart(
      final SavingTableCompanion savingTableCompanion, final String savingId);
}
