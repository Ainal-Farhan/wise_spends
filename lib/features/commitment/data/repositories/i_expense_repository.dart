import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/expense/expense_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class IExpenseRepository extends ICrudRepository<ExpenseTable,
    $ExpenseTableTable, ExpenseTableCompanion, ExpnsExpense> {
  IExpenseRepository(AppDatabase db) : super(db, db.expenseTable);
}
