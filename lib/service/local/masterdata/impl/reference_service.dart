import 'package:wise_spends/repository/masterdata/impl/reference_repository.dart';
import 'package:wise_spends/service/local/masterdata/i_reference_service.dart';

class ReferenceService extends IReferenceService {
  ReferenceService() : super(ReferenceRepository());
}
