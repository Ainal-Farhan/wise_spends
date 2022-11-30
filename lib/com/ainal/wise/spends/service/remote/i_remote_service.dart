import 'package:wise_spends/com/ainal/wise/spends/service/rest_service/i_rest_crud_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/i_service.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/rest_service/impl/rest_crud_service.dart';

abstract class IRemoteService<T> implements IService<T> {
  final IRestCrudService restCrudService = RestCrudService();
}
