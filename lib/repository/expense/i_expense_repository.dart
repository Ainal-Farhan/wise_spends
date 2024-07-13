import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/db/domain/expense/expense_table.dart';
import 'package:wise_spends/repository/i_crud_repository.dart';

abstract class IExpenseRepository extends ICrudRepository<ExpenseTable,
    $ExpenseTableTable, ExpenseTableCompanion, ExpnsExpense> {
  IExpenseRepository(AppDatabase db) : super(db, db.expenseTable);
}
