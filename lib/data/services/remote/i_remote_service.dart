import 'package:wise_spends/data/services/i_service.dart';
import 'package:wise_spends/data/services/rest_service/i_rest_crud_service.dart';
import 'package:wise_spends/data/services/rest_service/impl/rest_crud_service.dart';

abstract class IRemoteService extends IService {
  final IRestCrudService restCrudService = RestCrudService();
}
