import 'package:drift/drift.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/repository/i_stream_repository.dart';

abstract class ICrudRepository<
  A extends BaseEntityTable, // The table definition
  B extends TableInfo<A, D>, // Drift’s table info type
  C extends UpdateCompanion<D>, // Companion (insert/update helper)
  D extends DataClass
>
    extends IStreamRepository<A, B, C, D> {
  ICrudRepository(super.db, super.table);

  String getTypeName();

  String tableName() => getTypeName();

  // Save using either data class or companion
  Future<D> save(Insertable<D> item) async {
    return await db.into(table).insertReturning(item);
  }

  Future<void> saveAll(List<Insertable<D>> items) async {
    if (items.isEmpty) return;
    await db.batch((batch) => batch.insertAll(table, items));
  }

  Future<D> insertOne(C companion) async {
    return await db.into(table).insertReturning(companion);
  }

  // Update using data class
  Future<void> update(Insertable<D> item) async {
    await db.update(table).replace(item);
  }

  // Partial update using companion
  Future<void> updatePart({
    required C tableCompanion,
    required String id,
  }) async {
    await (db.update(
      table,
    )..where((tbl) => tbl.id.equals(id))).write(tableCompanion);
  }

  Future<List<D>> findAll() async {
    return await db.select(table).get();
  }

  Future<D?> findById({required String id}) {
    return (db.select(
      table,
    )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Stream<D?> watchById({required String id}) {
    return (db.select(
      table,
    )..where((tbl) => tbl.id.equals(id))).watchSingleOrNull();
  }

  Future<void> deleteById({required String id}) async {
    await (db.delete(table)..where((tbl) => tbl.id.equals(id))).go();
  }

  Future<void> delete(Insertable<D> item) async {
    await db.delete(table).delete(item);
  }

  Future<void> deleteAll() async {
    await db.delete(table).go();
  }

  Future saveAllFromTableCompanion(final List<C> items) async {
    if (items.isEmpty) {
      return;
    }
    await db.batch((batch) => batch.insertAll(table, items));
  }
}
