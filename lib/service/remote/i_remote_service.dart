import 'package:wise_spends/service/rest_service/i_rest_crud_service.dart';
import 'package:wise_spends/service/i_service.dart';
import 'package:wise_spends/service/rest_service/impl/rest_crud_service.dart';

abstract class IRemoteService extends IService {
  final IRestCrudService restCrudService = RestCrudService();
}
