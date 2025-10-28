import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/data/services/local/masterdata/i_reference_service.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';

class ReferenceService extends IReferenceService {
  ReferenceService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getReferenceRepository());
}
