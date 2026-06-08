import 'package:wise_spends/data/db/domain/lending/lending_table.dart';
import 'package:wise_spends/data/db/domain/lending/lending_repayment_table.dart';

export './lending_table.dart';
export './lending_repayment_table.dart';

abstract class Lending {
  static const List<dynamic> tableList = [LendingTable, LendingRepaymentTable];
}
