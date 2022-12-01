import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/common/i_stream_repository.dart';

abstract class ICrudRepository<T, P extends UpdateCompanion<T>>
    extends IStreamRepository<T, P> {
  const ICrudRepository(AppDatabase db, TableInfo<Table, T> table)
      : super(db, table);

  Future<void> save(final item) async {
    await db.into(table).insert(item);
  }

  // update all columns except primary key
  Future<void> update(final item) async {
    await db.update(table).replace(item);
  }

  // update all non null attributes from entity except primary key
  Future<void> updatePart(final P item) async {
    await db.update(table).write(item);
  }

  Future<List<T>> findAll() async {
    return await db.select(table).get();
  }

  Future<void> delete(final item) async {
    await db.delete(table).delete(item);
  }
}
