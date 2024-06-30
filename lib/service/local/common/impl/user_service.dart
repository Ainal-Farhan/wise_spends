import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/repository/common/i_user.repository.dart';
import 'package:wise_spends/service/local/common/i_user_service.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class UserService extends IUserService {
  final IUserRepository _userRepository =
      SingletonUtil.getSingleton<IRepositoryLocator>()!.getUserRepository();

  UserService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getUserRepository());

  @override
  Stream<CmmnUser?> findById(String id) {
    return _userRepository.watchById(id: id);
  }

  @override
  Future<CmmnUser?> findByName(String name) async {
    return await _userRepository.findByName(name);
  }
}
