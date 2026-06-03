import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/common/user_table.dart';

@DataClassName("${DomainTableConstant.creditCardTablePrefix}CreditCard")
class CreditCardTable extends BaseEntityTable {
  TextColumn get name => text()();
  TextColumn get lastFourDigits => text().nullable()();
  RealColumn get creditLimit => real()();
  IntColumn get statementDay => integer()();
  IntColumn get dueDay => integer()();
  TextColumn get note => text().nullable()();
  TextColumn get userId => text().nullable().references(UserTable, #id)();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'name': name.name,
      'lastFourDigits': lastFourDigits.name,
      'creditLimit': creditLimit.name,
      'statementDay': statementDay.name,
      'dueDay': dueDay.name,
      'note': note.name,
      'userId': userId.name,
    };
  }
}
