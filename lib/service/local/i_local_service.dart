import 'package:wise_spends/repository/i_crud_repository.dart';
import 'package:wise_spends/service/i_service.dart';

abstract class ILocalService implements IService {
  final ICrudRepository crudRepository;

  ILocalService(this.crudRepository);

  @override
  Future<dynamic> add(final item) async {
    return await crudRepository.save(item);
  }

  @override
  Future<void> delete(final item) async {
    await crudRepository.delete(item);
  }

  @override
  Future<List<dynamic>> get() async {
    return await crudRepository.findAll();
  }

  @override
  Future<void> update(final item) async {
    await crudRepository.update(item);
  }
}
