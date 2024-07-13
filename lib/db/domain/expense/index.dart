export './expense_table.dart';
export './commitent_table.dart';
export './commitment_detail_table.dart';

import 'package:wise_spends/db/domain/expense/commitent_table.dart';
import 'package:wise_spends/db/domain/expense/commitment_detail_table.dart';
import 'package:wise_spends/db/domain/expense/expense_table.dart';

abstract class Expense {
  static const List<dynamic> tableList = [
    ExpenseTable,
    CommitmentDetailTable,
    CommitmentTable,
  ];
}
