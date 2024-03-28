import 'package:wise_spends/repository/i_crud_repository.dart';
import 'package:wise_spends/service/local/i_local_service.dart';

abstract class IGroupReferenceService extends ILocalService {
  IGroupReferenceService(ICrudRepository crudRepository)
      : super(crudRepository);
}
