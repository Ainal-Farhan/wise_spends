import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/masterdata/i_reference_repository.dart';

class ReferenceRepository extends IReferenceRepository {
  ReferenceRepository() : super(AppDatabase());
  
  @override
  String getTypeName() => 'ReferenceTable';
}
