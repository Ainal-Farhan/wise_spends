import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_user.repository.dart';

class UserRepository extends IUserRepository {
  UserRepository() : super(AppDatabase());

  @override
  Stream<CmnUser?> findById(String id) {
    return (db.select(db.userTable)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  @override
  Stream<CmnUser?> findByName(final String name) {
    return (db.select(db.userTable)..where((tbl) => tbl.name.equals(name)))
        .watchSingleOrNull();
  }
}
