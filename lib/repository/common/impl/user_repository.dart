import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/common/i_user.repository.dart';

class UserRepository extends IUserRepository {
  UserRepository() : super(AppDatabase());

  @override
  Future<CmmnUser?> findByName(final String name) async {
    return (db.select(db.userTable)..where((tbl) => tbl.name.equals(name)))
        .getSingleOrNull();
  }

  @override
  Future<CmmnUser?> findAnyone() async {
    return await (db.select(db.userTable)).getSingleOrNull();
  }
}
