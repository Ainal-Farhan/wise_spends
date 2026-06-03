import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_payment_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICreditCardPaymentRepository
    extends
        ICrudRepository<
          CreditCardPaymentTable,
          $CreditCardPaymentTableTable,
          CreditCardPaymentTableCompanion,
          CrdCardPayment
        > {
  ICreditCardPaymentRepository(AppDatabase db)
    : super(db, db.creditCardPaymentTable);

  Future<List<CrdCardPayment>> getPaymentsForCard(String cardId);
  Future<void> addPayment({
    required String creditCardId,
    required String sourceSavingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
  });
  Future<double> getTotalPaid(String cardId);
}
