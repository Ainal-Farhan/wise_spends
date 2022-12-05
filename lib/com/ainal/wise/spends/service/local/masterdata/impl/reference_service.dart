import 'package:wise_spends/com/ainal/wise/spends/repository/masterdata/impl/reference_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/masterdata/i_reference_service.dart';

class ReferenceService extends IReferenceService {
  ReferenceService() : super(ReferenceRepository());
}
