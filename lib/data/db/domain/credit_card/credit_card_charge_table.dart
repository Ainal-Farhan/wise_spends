import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';

@DataClassName("${DomainTableConstant.creditCardTablePrefix}Charge")
class CreditCardChargeTable extends BaseEntityTable {
  TextColumn get creditCardId => text().references(CreditCardTable, #id)();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().nullable().references(CategoryTable, #id)();
  DateTimeColumn get chargeDate => dateTime()();
  TextColumn get note => text().nullable()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'creditCardId': creditCardId.name,
      'description': description.name,
      'amount': amount.name,
      'categoryId': categoryId.name,
      'chargeDate': chargeDate.name,
      'note': note.name,
    };
  }
}
