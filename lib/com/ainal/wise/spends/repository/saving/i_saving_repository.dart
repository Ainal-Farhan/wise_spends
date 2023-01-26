import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';

abstract class ISavingRepository extends ICrudRepository<$SavingTableTable,
    SavingTableCompanion, SvngSaving> {
  ISavingRepository(AppDatabase db) : super(db, db.savingTable);

  Stream<SvngSaving> watchBasedOnSavingId(final String savingId);

  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId);

  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(
      final String moneyStorageId);

  Future<void> updatePart(
      final SavingTableCompanion savingTableCompanion, final String savingId);
}
