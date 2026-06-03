import 'package:wise_spends/data/db/domain/credit_card/credit_card_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_charge_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_payment_table.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_charge_payment_table.dart';

export './credit_card_table.dart';
export './credit_card_charge_table.dart';
export './credit_card_payment_table.dart';
export './credit_card_charge_payment_table.dart';

abstract class CreditCard {
  static const List<dynamic> tableList = [
    CreditCardTable,
    CreditCardChargeTable,
    CreditCardPaymentTable,
    CreditCardChargePaymentTable,
  ];
}
