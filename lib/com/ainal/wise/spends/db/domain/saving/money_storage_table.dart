import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/index.dart';

@DataClassName("${DomainTableConstant.savingTablePrefix}MoneyStorage")
class MoneyStorageTable extends BaseEntityTable {
  TextColumn get iconUrl => text().withDefault(const Constant(''))();
  TextColumn get longName => text().unique()();
  TextColumn get shortName => text().unique()();
  TextColumn get type => text()();
  TextColumn get userId => text().nullable().references(UserTable, #id)();
}
