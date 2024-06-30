import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/common/user_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class IUserRepository extends ICrudRepository<UserTable,
    $UserTableTable, UserTableCompanion, CmmnUser> {
  IUserRepository(AppDatabase db) : super(db, db.userTable);

  Future<CmmnUser?> findByName(final String name);

  Future<CmmnUser?> findAnyone();
}
