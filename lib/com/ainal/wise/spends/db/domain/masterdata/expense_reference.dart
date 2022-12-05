import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/masterdata/reference_table.dart';

@DataClassName(DomainTableConstant.masterdataTablePrefix + 'ExpenseReference')
class ExpenseReferenceTable extends BaseEntityTable {
  RealColumn get suggestedAmount => real().withDefault(const Constant(.0))();
  TextColumn get description => text().nullable()();
  TextColumn get referenceId => text().references(ReferenceTable, #id)();
}
