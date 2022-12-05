import 'package:wise_spends/com/ainal/wise/spends/repository/masterdata/impl/group_reference_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/masterdata/i_group_reference_service.dart';

class GroupReferenceService extends IGroupReferenceService {
  GroupReferenceService() : super(GroupReferenceRepository());
}
