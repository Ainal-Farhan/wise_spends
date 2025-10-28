import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/masterdata/reference_table.dart';

@DataClassName('${DomainTableConstant.masterdataTablePrefix}ExpenseReference')
class ExpenseReferenceTable extends BaseEntityTable {
  RealColumn get suggestedAmount => real().withDefault(const Constant(.0))();
  TextColumn get description => text().nullable()();
  TextColumn get referenceId => text().references(ReferenceTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'suggestedAmount': suggestedAmount.toString(),
      'description': description.toString(),
      'referenceId': referenceId.toString()
    };
  }
}
