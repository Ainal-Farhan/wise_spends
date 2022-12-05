import 'package:drift/drift.dart';
import 'package:wise_spends/com/ainal/wise/spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/expense/expense_table.dart';
import 'package:wise_spends/com/ainal/wise/spends/db/domain/saving/saving_table.dart';

@DataClassName(DomainTableConstant.transactionTablePrefix + "Transaction")
class TransactionTable extends BaseEntityTable {
  // TextColumn get type =>
  //     text().check(type.isIn(DomainTableConstant.transactionTableTypeList))();
  TextColumn get type => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount =>
      real().check(amount.isBiggerThan(const Constant(0)))();
  TextColumn get savingId => text().references(SavingTable, #id)();
  BoolColumn get isExpense => boolean().withDefault(const Constant(false))();
  TextColumn get expenseId => text().nullable().references(ExpenseTable, #id)();
}
