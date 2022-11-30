import 'package:wise_spends/com/ainal/wise/spends/service/remote/i_remote_service.dart';

class RemoteService<T> extends IRemoteService<T> {
  @override
  Future<void> add(T item) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(T item) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> get() async {
    throw UnimplementedError();
  }

  @override
  Future<void> update(T item) async {
    throw UnimplementedError();
  }
}
