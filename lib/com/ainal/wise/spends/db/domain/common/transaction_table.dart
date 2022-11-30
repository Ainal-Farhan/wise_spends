import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/saving_table.dart';

@DataClassName(DomainTableConstant.commonTablePrefix + "Transaction")
class TransactionTable extends BaseEntityTable {
  TextColumn get type => text()();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real()();
  TextColumn get saving => text().references(SavingTable, #id)();
}
