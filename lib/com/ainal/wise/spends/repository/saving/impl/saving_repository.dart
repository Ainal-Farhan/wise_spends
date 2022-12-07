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
}