abstract class IService {
  Future<List<dynamic>> get();
  Future<void> delete(final item);
  Future<void> update(final item);
  Future<dynamic> add(final item);
}
