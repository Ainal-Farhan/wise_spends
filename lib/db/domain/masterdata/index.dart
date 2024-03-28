export './expense_reference.dart';
export './group_reference_table.dart';
export './reference_data_table.dart';
export './reference_table.dart';

import 'package:wise_spends/db/domain/masterdata/expense_reference.dart';
import 'package:wise_spends/db/domain/masterdata/group_reference_table.dart';
import 'package:wise_spends/db/domain/masterdata/reference_data_table.dart';
import 'package:wise_spends/db/domain/masterdata/reference_table.dart';

abstract class MasterData {
  static const List<dynamic> tableList = [
    ReferenceTable,
    ReferenceDataTable,
    GroupReferenceTable,
    ExpenseReferenceTable,
  ];
}
