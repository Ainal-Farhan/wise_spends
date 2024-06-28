import 'package:wise_spends/singleton/i_singleton.dart';

abstract class IService extends ISingleton {
  Future<List<dynamic>> get();
  Future<void> delete(final item);
  Future<void> update(final item);
  Future<dynamic> add(final item);
}
