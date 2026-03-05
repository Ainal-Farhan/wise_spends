import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/expense/expense_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

@DataClassName("${DomainTableConstant.transactionTablePrefix}Transaction")
class TransactionTable extends BaseEntityTable {
  TextColumn get type => textEnum<TransactionType>()();
  TextColumn get description => text().withDefault(const Constant(''))();
  RealColumn get amount =>
      real().customConstraint('CHECK (amount > 0) NOT NULL')();
  TextColumn get savingId => text().references(SavingTable, #id)();
  TextColumn get expenseId => text().nullable().references(ExpenseTable, #id)();
  DateTimeColumn get transactionDateTime => dateTime().nullable()();
  TextColumn get transferGroupId => text().nullable()();
  TextColumn get transferType => text().nullable()(); // 'debit' | 'credit'
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'type': type.toString(),
      'description': description.toString(),
      'amount': amount.toString(),
      'savingId': savingId.toString(),
      'expenseId': expenseId.toString(),
      'transactionDateTime': transactionDateTime.toString(),
      'transferGroupId': transferGroupId.toString(),
      'transferType': transferType.toString(),
      'note': note.toString(),
    };
  }
}
