import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_user.repository.dart';

class UserRepository extends IUserRepository {
  UserRepository() : super(AppDatabase());
}
