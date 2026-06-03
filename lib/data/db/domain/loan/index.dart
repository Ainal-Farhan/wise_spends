import 'package:wise_spends/data/db/domain/loan/loan_table.dart';
import 'package:wise_spends/data/db/domain/loan/loan_repayment_table.dart';

export './loan_table.dart';
export './loan_repayment_table.dart';

abstract class Loan {
  static const List<dynamic> tableList = [LoanTable, LoanRepaymentTable];
}
