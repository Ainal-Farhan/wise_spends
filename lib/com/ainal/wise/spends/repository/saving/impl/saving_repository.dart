import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/saving/i_saving_repository.dart';

class SavingRepository extends ISavingRepository {
  SavingRepository() : super(AppDatabase());

  @override
  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId) {
    return (db.select(db.savingTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }

  @override
  Stream<SvngSaving> watchBasedOnSavingId(String savingId) {
    return (db.select(db.savingTable)..where((tbl) => tbl.id.equals(savingId)))
        .watchSingle();
  }

  @override
  Future<void> updatePart(
      SavingTableCompanion savingTableCompanion, final String savingId) async {
    await (db.update(db.savingTable)..where((tbl) => tbl.id.equals(savingId)))
        .write(savingTableCompanion);
  }

  @override
  Stream<List<SvngSaving>> watchBasedOnMoneyStorageId(String moneyStorageId) {
    return (db.select(db.savingTable)
          ..where((tbl) => tbl.moneyStorageId.equals(moneyStorageId)))
        .watch();
  }
}
