import 'package:drift/drift.dart';
import 'package:wise_spends/db/app_database.dart';

abstract class IStreamRepository<A extends TableInfo<A, C>,
    B extends UpdateCompanion<C>, C extends Insertable<C>> {
  final AppDatabase db;
  final A table;

  const IStreamRepository(this.db, this.table);

  Stream<List<C>> watch() {
    return db.select(table).watch();
  }
}
