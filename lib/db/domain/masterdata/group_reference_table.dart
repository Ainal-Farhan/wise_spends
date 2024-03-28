import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';

@DataClassName('${DomainTableConstant.masterdataTablePrefix}GroupReference')
class GroupReferenceTable extends BaseEntityTable {
  TextColumn get label => text()();
  TextColumn get value => text()();
}
