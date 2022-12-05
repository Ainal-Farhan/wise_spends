import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/masterdata/i_reference_repository.dart';

class ReferenceRepository extends IReferenceRepository {
  ReferenceRepository() : super(AppDatabase());
}
