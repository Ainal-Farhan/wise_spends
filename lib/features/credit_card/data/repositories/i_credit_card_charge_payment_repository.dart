import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_charge_payment_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICreditCardChargePaymentRepository
    extends
        ICrudRepository<
          CreditCardChargePaymentTable,
          $CreditCardChargePaymentTableTable,
          CreditCardChargePaymentTableCompanion,
          CrdCardChargePayment
        > {
  ICreditCardChargePaymentRepository(AppDatabase db)
    : super(db, db.creditCardChargePaymentTable);

  Future<List<CrdCardChargePayment>> getAllocationsForCharge(String chargeId);
  Future<List<CrdCardChargePayment>> getAllocationsForPayment(String paymentId);
}
