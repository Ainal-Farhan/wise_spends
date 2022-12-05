import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';

abstract class IUserRepository
    extends ICrudRepository<$UserTableTable, UserTableCompanion, CmmnUser> {
  IUserRepository(AppDatabase db) : super(db, db.userTable);

  Stream<CmmnUser?> findById(final String id);

  SingleOrNullSelectable<CmmnUser?> findByName(final String name);
}
