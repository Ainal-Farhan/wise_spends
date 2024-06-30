import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/masterdata/i_reference_repository.dart';

class ReferenceRepository extends IReferenceRepository {
  ReferenceRepository() : super(AppDatabase());
  
  @override
  String getTypeName() => 'ReferenceTable';
}
