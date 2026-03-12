import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/commitment/data/repositories/i_payee_repository.dart';

/// Payee Repository Implementation
class PayeeRepository extends IPayeeRepository {
  PayeeRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'PayeeTable';

  @override
  Stream<List<ExpnsPayee>> watchAll() {
    return (db.select(
      table,
    )..orderBy([(t) => OrderingTerm.asc(t.name)])).watch();
  }

  @override
  Stream<List<ExpnsPayee>> watchByName(String query) {
    return (db.select(table)
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  @override
  ExpnsPayee fromJson(Map<String, dynamic> json) => ExpnsPayee.fromJson(json);
}
