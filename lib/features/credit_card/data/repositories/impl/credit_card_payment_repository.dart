import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_payment_repository.dart';

class CreditCardPaymentRepository extends ICreditCardPaymentRepository {
  CreditCardPaymentRepository() : super(AppDatabase());

  @override
  Future<List<CrdCardPayment>> getPaymentsForCard(String cardId) {
    return (db.select(
      db.creditCardPaymentTable,
    )..where((t) => t.creditCardId.equals(cardId))).get();
  }

  @override
  Future<void> addPayment({
    required String creditCardId,
    required String sourceSavingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
  }) async {
    final now = DateTime.now();
    final paymentId = UuidGenerator().v4();
    await db
        .into(db.creditCardPaymentTable)
        .insert(
          CreditCardPaymentTableCompanion.insert(
            id: Value(paymentId),
            creditCardId: creditCardId,
            sourceSavingId: sourceSavingId,
            amount: amount,
            paymentDate: paymentDate,
            note: Value(note),
            createdBy: 'app',
            dateCreated: Value(now),
            dateUpdated: now,
            lastModifiedBy: 'app',
          ),
        );
    if (chargeAllocations != null) {
      for (final alloc in chargeAllocations) {
        await db
            .into(db.creditCardChargePaymentTable)
            .insert(
              CreditCardChargePaymentTableCompanion.insert(
                id: Value(UuidGenerator().v4()),
                chargeId: alloc.chargeId,
                paymentId: paymentId,
                allocatedAmount: alloc.amount,
                createdBy: 'app',
                dateCreated: Value(now),
                dateUpdated: now,
                lastModifiedBy: 'app',
              ),
            );
      }
    }
  }

  @override
  Future<double> getTotalPaid(String cardId) async {
    final payments = await getPaymentsForCard(cardId);
    return payments.fold<double>(0.0, (sum, p) => sum + p.amount);
  }

  @override
  String getTypeName() => 'CreditCardPaymentTable';

  @override
  CrdCardPayment fromJson(Map<String, dynamic> json) =>
      CrdCardPayment.fromJson(json);
}
