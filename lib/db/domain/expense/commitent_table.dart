import 'package:drift/drift.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}Commitment")
class CommitmentTable extends BaseEntityTable {
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get referredSavingId => text().references(SavingTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.toString(),
      'description': description.toString(),
      'referredSavingId': referredSavingId.toString()
    };
  }
}
