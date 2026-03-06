import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/expense/commitment_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/core/constants/constant/enum/expense/commitment_detail_type.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}CommitmentDetail")
class CommitmentDetailTable extends BaseEntityTable {
  RealColumn get amount => real()();
  TextColumn get description => text()();
  
  /// Recurrence pattern - using intEnum for type safety
  IntColumn get type => intEnum<CommitmentDetailType>()();
  
  TextColumn get savingId => text().references(SavingTable, #id)();
  TextColumn get commitmentId => text().references(CommitmentTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() => {
        'amount': amount.name,
        'description': description.name,
        'type': type.name,
        'savingId': savingId.name,
        'commitmentId': commitmentId.name,
      };
}
