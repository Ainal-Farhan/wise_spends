import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/masterdata/i_group_reference_repository.dart';

class GroupReferenceRepository extends IGroupReferenceRepository {
  GroupReferenceRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'GroupReferenceTable';
}
