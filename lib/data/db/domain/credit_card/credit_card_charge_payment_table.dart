import 'package:drift/drift.dart';
import 'package:wise_spends/core/constants/constant/domain/domain_table_constant.dart';
import 'package:wise_spends/data/db/domain/base/base_entity_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_charge_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_payment_table.dart';

@DataClassName("${DomainTableConstant.creditCardTablePrefix}ChargePayment")
class CreditCardChargePaymentTable extends BaseEntityTable {
  TextColumn get chargeId => text().references(CreditCardChargeTable, #id)();
  TextColumn get paymentId => text().references(CreditCardPaymentTable, #id)();
  RealColumn get allocatedAmount => real()();

  @override
  Map<String, dynamic> toMapFromSubClass() {
    return {
      'chargeId': chargeId.name,
      'paymentId': paymentId.name,
      'allocatedAmount': allocatedAmount.name,
    };
  }
}
