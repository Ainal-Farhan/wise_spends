import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';

@DataClassName(DomainTableConstant.commonTablePrefix + "Saving")
class SavingTable extends BaseEntityTable {
  TextColumn get name => text()();
  BoolColumn get isPublic => boolean()();
  BoolColumn get isHasGoal => boolean()();
  RealColumn get goal => real()();
  BoolColumn get isHasStartDate => boolean()();
  DateTimeColumn get startDate => dateTime()();
  BoolColumn get isHasEndDate => boolean()();
  DateTimeColumn get endDate => dateTime()();
  BoolColumn get isSaveDaily => boolean()();
  BoolColumn get isSaveWeekly => boolean()();
  BoolColumn get isSaveMonthly => boolean()();
  RealColumn get currentAmount => real()();
}
