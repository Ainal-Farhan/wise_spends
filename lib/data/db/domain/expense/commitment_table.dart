import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/common/user_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}Commitment")
class CommitmentTable extends BaseEntityTable {
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get referredSavingId => text().references(SavingTable, #id)();
  TextColumn get userId => text().references(UserTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.toString(),
      'description': description.toString(),
      'referredSavingId': referredSavingId.toString(),
      'userId': userId.toString(),
    };
  }
}
