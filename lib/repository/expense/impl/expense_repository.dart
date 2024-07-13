import 'package:wise_spends/db/app_database.dart';
import 'package:wise_spends/repository/expense/i_expense_repository.dart';

class ExpenseRepository extends IExpenseRepository {
  ExpenseRepository() : super(AppDatabase());

  @override
  String getTypeName() => 'ExpenseTable';
}
