import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/service/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/utils/singleton_util.dart';

class ReferenceService extends IReferenceService {
  ReferenceService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getReferenceRepository());
}
