import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/app_database.dart';

abstract class IStreamRepository<T, P extends UpdateCompanion<T>> {
  final AppDatabase db;
  final TableInfo<Table, T> table;

  const IStreamRepository(this.db, this.table);

  Stream<List<T>> watch() {
    return db.select(table).watch();
  }
}
