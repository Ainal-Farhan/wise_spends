import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/masterdata/reference_data_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Reference Data Repository Interface
abstract class IReferenceDataRepository
    extends
        ICrudRepository<
          ReferenceDataTable,
          $ReferenceDataTableTable,
          ReferenceDataTableCompanion,
          MstrdtReferenceData
        > {
  IReferenceDataRepository(AppDatabase db) : super(db, db.referenceDataTable);

  /// Watch all reference data for a reference
  Stream<List<MstrdtReferenceData>> watchByReferenceId(String referenceId);

  /// Get all reference data for a reference
  Future<List<MstrdtReferenceData>> getByReferenceId(String referenceId);
}
