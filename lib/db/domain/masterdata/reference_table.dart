import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/db/domain/masterdata/group_reference_table.dart';

@DataClassName('${DomainTableConstant.masterdataTablePrefix}Reference')
class ReferenceTable extends BaseEntityTable {
  TextColumn get label => text()();
  TextColumn get value => text().unique()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  TextColumn get belongTo => text().references(ReferenceTable, #id)();
  TextColumn get groupId => text().references(GroupReferenceTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'label': label.toString(),
      'value': value.toString(),
      'isActive': isActive.toString(),
      'belongTo': belongTo.toString(),
      'groupId': groupId.toString()
    };
  }
}
