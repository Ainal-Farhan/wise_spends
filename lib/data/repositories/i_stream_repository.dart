import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/di/i_singleton.dart';

abstract class IStreamRepository<
    A extends BaseEntityTable,
    B extends TableInfo<A, D>,
    C extends UpdateCompanion<D>,
    D extends DataClass> extends ISingleton {
  final AppDatabase db;
  final B table;

  IStreamRepository(this.db, this.table);

  Stream<List<D>> watch() {
    return db.select(table).watch();
  }
}
