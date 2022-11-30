import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';

@DataClassName(DomainTableConstant.commonTablePrefix + "User")
class UserTable extends BaseEntityTable {
  TextColumn get name => text()();
}
