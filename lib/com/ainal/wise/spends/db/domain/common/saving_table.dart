import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/common/user_table.dart';

@DataClassName(DomainTableConstant.commonTablePrefix + "Saving")
class SavingTable extends BaseEntityTable {
  TextColumn get name => text()();
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
  RealColumn get currentAmount => real().withDefault(const Constant(.0))();
  TextColumn get userId => text().references(UserTable, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
        {name}
      ];
}
