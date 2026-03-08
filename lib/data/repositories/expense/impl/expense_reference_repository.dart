import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_reference_repository.dart';

/// Expense Reference Repository Implementation
class ExpenseReferenceRepository extends IExpenseReferenceRepository {
  ExpenseReferenceRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'ExpenseReferenceTable';

  @override
  Stream<List<MstrdtExpenseReference>> watchAll() {
    return db.select(db.expenseReferenceTable).watch();
  }

  @override
  Future<List<MstrdtExpenseReference>> getAll() async {
    return db.select(db.expenseReferenceTable).get();
  }

  @override
  MstrdtExpenseReference fromJson(Map<String, dynamic> json) =>
      MstrdtExpenseReference.fromJson(json);
}
