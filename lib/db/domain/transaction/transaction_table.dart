import 'package:drift/drift.dart';
import 'package:wise_spends/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/db/domain/expense/expense_table.dart';
import 'package:wise_spends/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.transactionTablePrefix}Transaction")
class TransactionTable extends BaseEntityTable {
  // TextColumn get type =>
  //     text().check(type.isIn(DomainTableConstant.transactionTableTypeList))();
  TextColumn get type => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount =>
      real().customConstraint('CHECK (amount > 0) NOT NULL')();
  TextColumn get savingId => text().references(SavingTable, #id)();
  BoolColumn get isExpense => boolean().withDefault(const Constant(false))();
  TextColumn get expenseId => text().nullable().references(ExpenseTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'type': type.toString(),
      'description': description.toString(),
      'amount': amount.toString(),
      'savingId': savingId.toString(),
      'isExpense': isExpense.toString(),
      'expenseId': expenseId.toString()
    };
  }
}
