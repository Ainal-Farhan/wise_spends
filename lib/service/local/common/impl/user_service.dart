import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/common/impl/user_repository.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';

class UserService extends IUserService {
  final UserRepository _userRepository = UserRepository();

  UserService() : super(UserRepository());

  @override
  Stream<CmmnUser?> findById(String id) {
    return _userRepository.findById(id);
  }

  @override
  Future<CmmnUser?> findByName(String name) async {
    return await _userRepository.findByName(name).getSingleOrNull();
  }
}
