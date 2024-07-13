export './expense_table.dart';
export './commitment_table.dart';
export './commitment_detail_table.dart';
export './commitment_task_table.dart';

import 'package:wise_spends/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/db/domain/expense/commitment_detail_table.dart';
import 'package:wise_spends/db/domain/expense/commitment_task_table.dart';
import 'package:wise_spends/db/domain/expense/expense_table.dart';

abstract class Expense {
  static const List<dynamic> tableList = [
    ExpenseTable,
    CommitmentDetailTable,
    CommitmentTable,
    CommitmentTaskTable,
  ];
}
