import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/common/user_table.dart';
import 'package:wise_spends/data/db/domain/saving/money_storage_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';

@DataClassName("${DomainTableConstant.savingTablePrefix}Saving")
class SavingTable extends BaseEntityTable {
  TextColumn get name => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('MYR'))();
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
  
  /// Optional default category for transactions from this saving account
  TextColumn get categoryId =>
      text().nullable().references(CategoryTable, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {name},
  ];

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.name,
      'currency': currency.name,
      'isPublic': isPublic.name,
      'isHasGoal': isHasGoal.name,
      'goal': goal.name,
      'isHasStartDate': isHasStartDate.name,
      'type': type.name,
      'startDate': startDate.name,
      'isHasEndDate': isHasEndDate.name,
      'endDate': endDate.name,
      'isSaveDaily': isSaveDaily.name,
      'isSaveWeekly': isSaveWeekly.name,
      'isSaveMonthly': isSaveMonthly.name,
      'currentAmount': currentAmount.name,
      'userId': userId.name,
      'moneyStorageId': moneyStorageId.name,
      'categoryId': categoryId.name,
    };
  }
}
