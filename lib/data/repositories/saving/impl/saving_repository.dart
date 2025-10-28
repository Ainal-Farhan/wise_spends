import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/composite/saving_with_money_storage.dart';
import 'package:wise_spends/data/repositories/saving/i_saving_repository.dart';

class SavingRepository extends ISavingRepository {
  SavingRepository() : super(AppDatabase());

  @override
  Stream<List<SvngSaving>> watchBasedOnUserId(final String userId) {
    return (db.select(db.savingTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watch();
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

  @override
  String getTypeName() => 'SavingTable';
}
