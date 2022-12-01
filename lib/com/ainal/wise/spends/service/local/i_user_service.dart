import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_local_service.dart';

abstract class IUserService extends ILocalService {
  IUserService(ICrudRepository repository) : super(repository);

  Stream<CmnUser?> findById(final String id);

  Future<CmnUser?> findByName(final String name);
}
