import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';
import 'package:wise_spends/com/ainal/wise/spends/repository/i_stream_repository.dart';

abstract class ICrudRepository<
    A extends TableInfo<A, C>,
    B extends UpdateCompanion<C>,
    C extends Insertable<C>> extends IStreamRepository<A, B, C> {
  const ICrudRepository(AppDatabase db, A table) : super(db, table);

  Future<C> save(final item) async {
    return await db.into(table).insertReturning(item);
  }

  // update all columns except primary key
  Future<void> update(final C item) async {
    await db.update(table).replace(item);
  }

  // update all non null attributes from entity except primary key
  Future<void> updatePart(final B item) async {
    await db.update(table).write(item);
  }

  Future<List<C>> findAll() async {
    return await db.select(table).get();
  }

  Future<void> delete(final item) async {
    await db.delete(table).delete(item);
  }
}
