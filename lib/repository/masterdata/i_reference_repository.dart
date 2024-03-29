import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/masterdata/reference_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class IReferenceRepository extends ICrudRepository<ReferenceTable,
    $ReferenceTableTable, ReferenceTableCompanion, MstrdtReference> {
  IReferenceRepository(AppDatabase db) : super(db, db.referenceTable);
}
