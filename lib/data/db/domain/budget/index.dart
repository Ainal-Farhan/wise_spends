import 'package:wise_spends/data/db/domain/budget/spending_budget_table.dart';

export './spending_budget_table.dart';

abstract class Budget {
  static const List<dynamic> tableList = [
    SpendingBudgetTable,
  ];
}
