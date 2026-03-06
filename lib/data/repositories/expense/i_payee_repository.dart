import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/payee_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Payee Repository Interface
abstract class IPayeeRepository
    extends
        ICrudRepository<
          PayeeTable,
          $PayeeTableTable,
          PayeeTableCompanion,
          ExpnsPayee
        > {
  IPayeeRepository(AppDatabase db) : super(db, db.payeeTable);

  /// Watch all payees ordered by name.
  Stream<List<ExpnsPayee>> watchAll();

  /// Watch payees whose name contains [query] (case-insensitive).
  Stream<List<ExpnsPayee>> watchByName(String query);
}
