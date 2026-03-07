import 'package:drift/drift.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';

@DataClassName('RecurringTransaction')
class RecurringTransactionTable extends BaseEntityTable {
  TextColumn get name => text()();
  TextColumn get type => text()(); // income | expense
  RealColumn get amount =>
      real().customConstraint('NOT NULL CHECK (amount > 0)')();
  TextColumn get savingId => text().references(SavingTable, #id)();
  TextColumn get categoryId =>
      text().nullable().references(CategoryTable, #id)();
  TextColumn get frequency => text()(); // daily | weekly | monthly | yearly
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  DateTimeColumn get nextRunDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.name,
      'type': type.name,
      'amount': amount.name,
      'savingId': savingId.name,
      'categoryId': categoryId.name,
      'frequency': frequency.name,
      'startDate': startDate.name,
      'endDate': endDate.name,
      'nextRunDate': nextRunDate.name,
      'isActive': isActive.name,
      'note': note.name,
    };
  }
}
