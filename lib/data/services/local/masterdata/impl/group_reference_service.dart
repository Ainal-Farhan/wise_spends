import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/services/local/masterdata/i_group_reference_service.dart';

class GroupReferenceService extends IGroupReferenceService {
  GroupReferenceService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getGroupReferenceRepository());
}
