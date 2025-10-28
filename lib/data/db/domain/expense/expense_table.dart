import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/masterdata/reference_data_table.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}Expense")
class ExpenseTable extends BaseEntityTable {
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get referenceDataId =>
      text().references(ReferenceDataTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'amount': amount.toString(),
      'description': description.toString(),
      'expenseDate': expenseDate.toString(),
      'referenceDataId': referenceDataId.toString()
    };
  }
}
