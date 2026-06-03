import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_table.dart';
import 'package:wise_spends/data/db/domain/saving/saving_table.dart';
import 'package:wise_spends/data/db/domain/transaction/category_table.dart';

@DataClassName("${DomainTableConstant.creditCardTablePrefix}Charge")
class CreditCardChargeTable extends BaseEntityTable {
  TextColumn get creditCardId => text().references(CreditCardTable, #id)();
  TextColumn get description => text()();
  RealColumn get amount => real()();
  TextColumn get categoryId => text().nullable().references(CategoryTable, #id)();
  DateTimeColumn get chargeDate => dateTime()();
  TextColumn get note => text().nullable()();
  /// Saving account to reserve/deduct from when this charge is paid.
  TextColumn get reservedSavingId =>
      text().nullable().references(SavingTable, #id)();

  /// Charge lifecycle status: 'posted' (default) or 'pending'.
  /// Pending charges are reserved but not yet confirmed by the bank.
  TextColumn get status =>
      text().withDefault(const Constant('posted'))();

  /// True when this entry is a credit/rebate from the card (e.g. cashback,
  /// points redemption).  Rebates reduce total debt instead of adding to it.
  BoolColumn get isRebate =>
      boolean().withDefault(const Constant(false))();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'creditCardId': creditCardId.name,
      'description': description.name,
      'amount': amount.name,
      'categoryId': categoryId.name,
      'chargeDate': chargeDate.name,
      'note': note.name,
      'reservedSavingId': reservedSavingId.name,
      'status': status.name,
      'isRebate': isRebate.name,
    };
  }
}
