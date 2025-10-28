import 'package:drift/drift.dart';
import 'package:wise_spends/core/di/i_singleton.dart';

abstract class IService extends ISingleton {
  Future<List<dynamic>> get();
  Future<void> delete(final Insertable<dynamic> item);
  Future<void> update(final Insertable<dynamic> item);
  Future<dynamic> add(final Insertable<dynamic> item);
}
