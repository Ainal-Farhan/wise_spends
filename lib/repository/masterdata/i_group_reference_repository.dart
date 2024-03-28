import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/masterdata/group_reference_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class IGroupReferenceRepository extends ICrudRepository<
    GroupReferenceTable,
    $GroupReferenceTableTable,
    GroupReferenceTableCompanion,
    MstrdtGroupReference> {
  IGroupReferenceRepository(AppDatabase db) : super(db, db.groupReferenceTable);
}
