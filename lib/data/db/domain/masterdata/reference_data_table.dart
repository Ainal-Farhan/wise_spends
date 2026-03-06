import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/masterdata/reference_table.dart';

@DataClassName('${DomainTableConstant.masterdataTablePrefix}ReferenceData')
class ReferenceDataTable extends BaseEntityTable {
  TextColumn get label => text()();
  TextColumn get groupLabel => text()();
  TextColumn get value => text()();
  TextColumn get groupValue => text()();
  TextColumn get referenceId =>
      text().nullable().references(ReferenceTable, #id)();
  BoolColumn get isHasNext => boolean().withDefault(const Constant(false))();
  TextColumn get nextReferenceDataId =>
      text().nullable().references(ReferenceDataTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'label': label.name,
      'groupLabel': groupLabel.name,
      'value': value.name,
      'groupValue': groupValue.name,
      'referenceId': referenceId.name,
      'isHasNext': isHasNext.name,
      'nextReferenceDataId': nextReferenceDataId.name,
    };
  }
}
