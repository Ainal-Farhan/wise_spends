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

  /// 'credit_card' or 'pay_later'
  TextColumn get cardType =>
      text().withDefault(const Constant('credit_card'))();

  /// Provider name for pay-later accounts (e.g. "Atome", "GrabPay Later")
  TextColumn get providerName => text().nullable()();

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
      'cardType': cardType.name,
      'providerName': providerName.name,
    };
  }
}
