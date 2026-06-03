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

  /// Returns payments for [cardId] on or after [since]. Pass null for all.
  Future<List<CrdCardPayment>> getPaymentsForCardSince(
      String cardId, DateTime? since);
  Future<void> addPayment({
    required String creditCardId,
    required String sourceSavingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
    /// Portions of charges covered by rebate credits.  Allocation rows are
    /// created so [getUnpaidAmount] is reduced, but **no saving balance is
    /// touched** for these entries.
    List<({String chargeId, double amount})>? rebateAllocations,
    /// Per-rebate consumed amounts — allocation rows are inserted so each
    /// rebate's remaining credit is correctly tracked.
    List<({String rebateId, double amount})>? appliedRebates,
  });
  Future<double> getTotalPaid(String cardId);
  Future<List<CrdCardChargePayment>> getPaymentAllocations(String paymentId);
  Future<void> deletePayment(String paymentId);
}
