import 'package:wise_spends/com/ainal/wise/spends/repository/i_crud_repository.dart';
import 'package:wise_spends/com/ainal/wise/spends/service/local/i_local_service.dart';

class LocalService<T> extends ILocalService<T> {
  final ICrudRepository crudRepository;

  LocalService(this.crudRepository);

  @override
  Future<void> add(T item) async {
    await crudRepository.save(item);
  }

  @override
  Future<void> delete(T item) async {
    await crudRepository.delete(item);
  }

  @override
  Future<List<dynamic>> get() async {
    return await crudRepository.findAll();
  }

  @override
  Future<void> update(T item) async {
    await crudRepository.update(item);
  }
}
