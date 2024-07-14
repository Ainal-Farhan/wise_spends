import 'package:drift/drift.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/repository/i_stream_repository.dart';

abstract class ICrudRepository<
    A extends BaseEntityTable,
    B extends TableInfo<A, D>,
    C extends UpdateCompanion<D>,
    D extends Insertable<D>> extends IStreamRepository<A, B, C, D> {
  ICrudRepository(super.db, super.table);

  /// Abstract method to get the type name of A
  String getTypeName();

  /// Method to get the table name
  String tableName() => getTypeName();

  Future saveAll(final List<D> items) async {
    if (items.isEmpty) {
      return;
    }

    await db.batch((batch) => batch.insertAll(table, items));
  }

  Future<D> save(final item) async {
    return await db.into(table).insertReturning(item);
  }

  // update all columns except primary key
  Future<void> update(final D item) async {
    await db.update(table).replace(item);
  }

  Future<void> updatePart(
      {required C tableCompanion, required final String id}) async {
    await (db.update(table)..where((tbl) => tbl.id.equals(id)))
        .write(tableCompanion);
  }

  Future<List<D>> findAll() async {
    return await db.select(table).get();
  }

  Future<D?> findById({required String id}) {
    return (db.select(table)..where((tbl) => tbl.id.equals(id)))
        .getSingleOrNull();
  }

  Stream<D?> watchById({required String id}) {
    return (db.select(table)..where((tbl) => tbl.id.equals(id)))
        .watchSingleOrNull();
  }

  Future<void> deleteById({required String id}) async {
    await (db.delete(table)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> delete(final D item) async {
    await db.delete(table).delete(item);
  }

  Future<void> deleteAll() async {
    await db.delete(table).go();
  }
}
