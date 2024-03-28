import 'package:wise_spends/service/remote/i_remote_service.dart';

class RemoteService<T> extends IRemoteService {
  @override
  Future<dynamic> add(final item) async {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(final item) async {
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> get() async {
    throw UnimplementedError();
  }

  @override
  Future<void> update(final item) async {
    throw UnimplementedError();
  }
}
