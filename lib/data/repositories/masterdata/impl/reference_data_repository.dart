import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_data_repository.dart';

/// Reference Data Repository Implementation
class ReferenceDataRepository extends IReferenceDataRepository {
  ReferenceDataRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'ReferenceDataTableTable';

  @override
  Stream<List<MstrdtReferenceData>> watchByReferenceId(String referenceId) {
    return (db.select(
      db.referenceDataTable,
    )..where((tbl) => tbl.referenceId.equals(referenceId))).watch();
  }

  @override
  Future<List<MstrdtReferenceData>> getByReferenceId(String referenceId) async {
    return (db.select(
      db.referenceDataTable,
    )..where((tbl) => tbl.referenceId.equals(referenceId))).get();
  }

  @override
  MstrdtReferenceData fromJson(Map<String, dynamic> json) =>
      MstrdtReferenceData.fromJson(json);
}
