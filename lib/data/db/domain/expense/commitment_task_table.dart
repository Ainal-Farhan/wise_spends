import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.expenseTablePrefix}CommitmentTask")
class CommitmentTaskTable extends BaseEntityTable {
  TextColumn get name => text()();
  RealColumn get amount => real()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  TextColumn get referredSavingId => text().references(SavingTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.toString(),
      'amount': amount.toString(),
      'idDone': isDone.toString(),
      'referredSavingId': referredSavingId.toString()
    };
  }
}
