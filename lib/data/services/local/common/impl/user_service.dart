import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/common/i_user.repository.dart';
import 'package:wise_spends/data/services/local/common/i_user_service.dart';

class UserService extends IUserService {
  final IUserRepository _userRepository =
      SingletonUtil.getSingleton<IRepositoryLocator>()!.getUserRepository();

  UserService()
    : super(
        SingletonUtil.getSingleton<IRepositoryLocator>()!.getUserRepository(),
      );

  @override
  Stream<CmmnUser?> findById(String id) {
    return _userRepository.watchById(id: id);
  }

  @override
  Future<CmmnUser?> findByName(String name) async {
    return await _userRepository.findByName(name);
  }

  @override
  Future<CmmnUser?> findOnlyOneInRandom() async {
    return await _userRepository.findAnyone();
  }
}
