import 'package:wise_spends/repository/masterdata/impl/group_reference_repository.dart';
import 'package:wise_spends/service/local/masterdata/i_group_reference_service.dart';

class GroupReferenceService extends IGroupReferenceService {
  GroupReferenceService() : super(GroupReferenceRepository());
}
