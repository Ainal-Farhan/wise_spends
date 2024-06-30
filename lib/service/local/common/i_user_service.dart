import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/service/local/i_local_service.dart';

abstract class IUserService extends ILocalService {
  IUserService(super.repository);

  Stream<CmmnUser?> findById(final String id);

  Future<CmmnUser?> findByName(final String name);

  /// Expected only one row of user data exist within db
  Future<CmmnUser?> findOnlyOneInRandom();
}
