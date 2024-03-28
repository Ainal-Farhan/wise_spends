import 'package:wise_spends/service/remote/i_remote_service.dart';

class RemoteService<T> extends IRemoteService {
  @override
  Future<dynamic> add(final item) async {
    return null;
  }

  @override
  Future<void> delete(final item) async {
    return;
  }

  @override
  Future<List<dynamic>> get() async {
    return List.empty();
  }

  @override
  Future<void> update(final item) async {
    return;
  }
}
