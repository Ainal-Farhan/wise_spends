import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/db/domain/common/user_table.dart';
import 'package:wise_spends/db/domain/saving/money_storage_table.dart';

@DataClassName("${DomainTableConstant.savingTablePrefix}Saving")
class SavingTable extends BaseEntityTable {
  TextColumn get name => text().nullable()();
  BoolColumn get isPublic => boolean().withDefault(const Constant(false))();
  BoolColumn get isHasGoal => boolean().withDefault(const Constant(false))();
  RealColumn get goal => real().withDefault(const Constant(.0))();
  BoolColumn get isHasStartDate =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get startDate => dateTime().nullable()();
  BoolColumn get isHasEndDate => boolean().withDefault(const Constant(false))();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isSaveDaily => boolean().withDefault(const Constant(false))();
  BoolColumn get isSaveWeekly => boolean().withDefault(const Constant(false))();
  BoolColumn get isSaveMonthly =>
      boolean().withDefault(const Constant(false))();
  TextColumn get type => text()();
  RealColumn get currentAmount => real().withDefault(const Constant(.0))();
  TextColumn get userId => text().nullable().references(UserTable, #id)();
  TextColumn get moneyStorageId =>
      text().nullable().references(MoneyStorageTable, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name}
      ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.toString(),
      'isPublic': isPublic.toString(),
      'isHasGoal': isHasGoal.toString(),
      'goal': goal.toString(),
      'isHasStartDate': isHasStartDate.toString(),
      'type': type.toString(),
      'startDate': startDate.toString(),
      'isHasEndDate': isHasEndDate.toString(),
      'endDate': endDate.toString(),
      'isSaveDaily': isSaveDaily.toString(),
      'isSaveWeekly': isSaveWeekly.toString(),
      'isSaveMonthly': isSaveMonthly.toString(),
      'currentAmount': currentAmount.toString(),
      'userId': userId.toString(),
      'moneyStorageId': moneyStorageId.toString()
    };
  }
}
