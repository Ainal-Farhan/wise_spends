abstract class IService<T> {
  Future<List<dynamic>> get();
  Future<void> delete(T item);
  Future<void> update(T item);
  Future<void> add(T item);
}
