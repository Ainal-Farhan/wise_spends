import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';

@DataClassName("${DomainTableConstant.creditCardTablePrefix}Payment")
class CreditCardPaymentTable extends BaseEntityTable {
  TextColumn get creditCardId => text().references(CreditCardTable, #id)();
  TextColumn get sourceSavingId => text().references(SavingTable, #id)();
  RealColumn get amount => real()();
  DateTimeColumn get paymentDate => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'creditCardId': creditCardId.name,
      'sourceSavingId': sourceSavingId.name,
      'amount': amount.name,
      'paymentDate': paymentDate.name,
      'note': note.name,
    };
  }
}
