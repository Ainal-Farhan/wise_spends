import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/masterdata/index.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

/// Expense Reference Repository Interface
abstract class IExpenseReferenceRepository
    extends
        ICrudRepository<
          ExpenseReferenceTable,
          $ExpenseReferenceTableTable,
          ExpenseReferenceTableCompanion,
          MstrdtExpenseReference
        > {
  IExpenseReferenceRepository(AppDatabase db)
    : super(db, db.expenseReferenceTable);

  /// Watch all expense references
  Stream<List<MstrdtExpenseReference>> watchAll();

  /// Get all expense references
  Future<List<MstrdtExpenseReference>> getAll();
}
