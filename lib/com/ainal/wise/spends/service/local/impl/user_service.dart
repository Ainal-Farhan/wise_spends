import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/impl/local_service.dart';

class UserService extends LocalService<CmnUser> {
  UserService() : super(UserRepository());
}
