import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/masterdata/i_group_reference_repository.dart';

class GroupReferenceRepository extends IGroupReferenceRepository {
  GroupReferenceRepository() : super(AppDatabase());
}
