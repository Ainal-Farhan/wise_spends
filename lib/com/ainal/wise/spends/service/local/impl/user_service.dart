import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_user_service.dart';

class UserService extends IUserService {
  final UserRepository _userRepository = UserRepository();

  UserService() : super(UserRepository());

  @override
  Stream<CmnUser?> findById(String id) {
    return _userRepository.findById(id);
  }

  @override
  Future<CmnUser?> findByName(String name) async {
    return await _userRepository.findByName(name).getSingleOrNull();
  }
}
