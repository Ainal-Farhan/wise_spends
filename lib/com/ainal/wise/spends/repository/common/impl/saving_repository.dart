import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_saving_repository.dart';

class SavingRepository extends ISavingRepository {
  SavingRepository() : super(AppDatabase());

  @override
  Stream<List<CmnSaving>> watchBasedOnUserId(final String userId) {
    return (db.select(db.savingTable)
          ..where((tbl) => tbl.userId.equals(userId)))
        .watch();
  }
}
