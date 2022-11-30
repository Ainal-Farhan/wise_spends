import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';

abstract class IUserRepository extends ICrudRepository<CmnUser> {
  IUserRepository(AppDatabase db) : super(db, db.userTable);
}