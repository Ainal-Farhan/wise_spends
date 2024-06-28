import 'package:wise_spends/locator/i_repository_locator.dart';
import 'package:wise_spends/service/local/masterdata/i_group_reference_service.dart';
import 'package:wise_spends/util/singleton_util.dart';

class GroupReferenceService extends IGroupReferenceService {
  GroupReferenceService()
      : super(SingletonUtil.getSingleton<IRepositoryLocator>()!
            .getGroupReferenceRepository());
}
