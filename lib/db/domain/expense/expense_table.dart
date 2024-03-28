import 'package:drift/drift.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/db/domain/masterdata/reference_data_table.dart';

class ExpenseTable extends BaseEntityTable {
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get expenseDate => dateTime()();
  TextColumn get referenceDataId =>
      text().references(ReferenceDataTable, #id)();
}
