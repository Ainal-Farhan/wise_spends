import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/db/domain/common/index.dart';

@DataClassName("${DomainTableConstant.savingTablePrefix}MoneyStorage")
class MoneyStorageTable extends BaseEntityTable {
  TextColumn get iconUrl => text().withDefault(const Constant(''))();
  TextColumn get longName => text().unique()();
  TextColumn get shortName => text().unique()();
  TextColumn get type => text()();
  TextColumn get userId => text().nullable().references(UserTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'iconUrl': iconUrl.toString(),
      'longName': longName.toString(),
      'shortName': shortName.toString(),
      'type': type.toString(),
      'userId': userId.toString()
    };
  }
}
