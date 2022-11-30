import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

abstract class ICrudRepository<T> {
  final AppDatabase db;
  final TableInfo<Table, T> table;

  const ICrudRepository(this.db, this.table);

  Future<void> save(final item) async {
    await db.into(table).insert(item);
  }

  Future<void> update(final item) async {
    await db.update(table).replace(item);
  }

  Future<List<T>> findAll() async {
    return await db.select(table).get();
  }

  Future<void> delete(final item) async {
    await db.delete(table).delete(item);
  }
}
