import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_user_service.dart';

class UserService extends IUserService {
  UserService() : super(UserRepository());
}
