import 'package:drift/drift.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/composite/saving_with_money_storage.dart';
import 'package:wise_spends/repository/saving/i_saving_repository.dart';

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

  @override
  Stream<List<SavingWithMoneyStorage>>
      watchSavingListWithMoneyStorageBasedOnUserId(String userId) {
    final query = db.select(db.savingTable).join([
      innerJoin(db.moneyStorageTable,
          db.moneyStorageTable.id.equalsExp(db.savingTable.moneyStorageId)),
    ])
      ..where(db.savingTable.userId.equals(userId));

    return query.watch().map((rows) => rows
        .map((row) => SavingWithMoneyStorage(
            saving: row.readTable(db.savingTable),
            moneyStorage: row.readTable(db.moneyStorageTable)))
        .toList());
  }
}
