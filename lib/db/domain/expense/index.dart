export './expense_table.dart';
import 'package:wise_spends/db/domain/expense/expense_table.dart';

abstract class Expense {
  static const List<dynamic> tableList = [ExpenseTable];
}
