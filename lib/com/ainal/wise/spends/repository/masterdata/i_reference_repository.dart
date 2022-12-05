import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';

abstract class IReferenceRepository extends ICrudRepository<
    $ReferenceTableTable, ReferenceTableCompanion, MstrdtReference> {
  IReferenceRepository(AppDatabase db) : super(db, db.referenceTable);
}
