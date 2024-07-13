import 'package:drift/drift.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}CommitmentDetail")
class CommitmentDetailTable extends BaseEntityTable {
  RealColumn get amount => real()();
  TextColumn get description => text()();
  TextColumn get type => text()();
  TextColumn get savingId => text().references(SavingTable, #id)();
  TextColumn get commitmentId => text().references(CommitmentTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'amount': amount.toString(),
      'description': description.toString(),
      'type': type.toString(),
      'savingId': savingId.toString(),
      'commitmentId': commitmentId.toString(),
    };
  }
}
