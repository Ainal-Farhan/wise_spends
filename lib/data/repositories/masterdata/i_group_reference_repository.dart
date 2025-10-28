import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/masterdata/group_reference_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class IGroupReferenceRepository extends ICrudRepository<
    GroupReferenceTable,
    $GroupReferenceTableTable,
    GroupReferenceTableCompanion,
    MstrdtGroupReference> {
  IGroupReferenceRepository(AppDatabase db) : super(db, db.groupReferenceTable);
}
