import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';

@DataClassName(DomainTableConstant.commonTablePrefix + "Transaction")
class TransactionTable extends BaseEntityTable {
  TextColumn get type => text()();
  TextColumn get description => text()();
  RealColumn get amount => real()();
}
