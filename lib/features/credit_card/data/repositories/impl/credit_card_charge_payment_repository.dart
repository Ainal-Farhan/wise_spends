import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_charge_payment_repository.dart';

class CreditCardChargePaymentRepository
    extends ICreditCardChargePaymentRepository {
  CreditCardChargePaymentRepository() : super(AppDatabase());

  @override
  Future<List<CrdCardChargePayment>> getAllocationsForCharge(String chargeId) {
    return (db.select(db.creditCardChargePaymentTable)
      ..where((t) => t.chargeId.equals(chargeId))).get();
  }

  @override
  Future<List<CrdCardChargePayment>> getAllocationsForPayment(
    String paymentId,
  ) {
    return (db.select(db.creditCardChargePaymentTable)
      ..where((t) => t.paymentId.equals(paymentId))).get();
  }

  @override
  String getTypeName() => 'CreditCardChargePaymentTable';

  @override
  CrdCardChargePayment fromJson(Map<String, dynamic> json) =>
      CrdCardChargePayment.fromJson(json);
}
