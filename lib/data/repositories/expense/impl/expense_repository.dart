import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/repositories/expense/i_expense_repository.dart';

class ExpenseRepository extends IExpenseRepository {
  ExpenseRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'ExpenseTable';
}
