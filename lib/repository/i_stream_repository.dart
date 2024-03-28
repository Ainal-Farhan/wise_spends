import 'package:drift/drift.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';

abstract class IStreamRepository<
    A extends BaseEntityTable,
    B extends TableInfo<A, D>,
    C extends UpdateCompanion<D>,
    D extends Insertable<D>> {
  final AppDatabase db;
  final B table;

  const IStreamRepository(this.db, this.table);

  Stream<List<D>> watch() {
    return db.select(table).watch();
  }
}
