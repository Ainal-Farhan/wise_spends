import 'package:drift/drift.dart';
import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/repository/i_stream_repository.dart';

abstract class ICrudRepository<
    A extends BaseEntityTable,
    B extends TableInfo<A, D>,
    C extends UpdateCompanion<D>,
    D extends Insertable<D>> extends IStreamRepository<A, B, C, D> {
  const ICrudRepository(AppDatabase db, B table) : super(db, table);

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
    db.delete(table).where((tbl) => tbl.id.equals(id));
  }

  Future<void> delete(final D item) async {
    await db.delete(table).delete(item);
  }
}
