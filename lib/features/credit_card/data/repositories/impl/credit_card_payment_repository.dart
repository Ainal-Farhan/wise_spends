import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_payment_repository.dart';

class CreditCardPaymentRepository extends ICreditCardPaymentRepository {
  CreditCardPaymentRepository() : super(AppDatabase());

  @override
  Future<List<CrdCardPayment>> getPaymentsForCard(String cardId) {
    return (db.select(db.creditCardPaymentTable)
          ..where((t) => t.creditCardId.equals(cardId)))
        .get();
  }

  @override
  Future<List<CrdCardPayment>> getPaymentsForCardSince(
      String cardId, DateTime? since) {
    final q = db.select(db.creditCardPaymentTable)
      ..where((t) => t.creditCardId.equals(cardId));
    if (since != null) {
      q.where((t) => t.paymentDate.isBiggerOrEqualValue(since));
    }
    return q.get();
  }

  @override
  Future<void> addPayment({
    required String creditCardId,
    required String sourceSavingId,
    required double amount,
    required DateTime paymentDate,
    String? note,
    List<({String chargeId, double amount})>? chargeAllocations,
    List<({String chargeId, double amount})>? rebateAllocations,
  }) async {
    final now = DateTime.now();
    final paymentId = UuidGenerator().v4();

    await db.into(db.creditCardPaymentTable).insert(
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

    if (chargeAllocations != null && chargeAllocations.isNotEmpty) {
      // Per-charge allocations: deduct from each charge's reservedSavingId if
      // set, otherwise fall back to sourceSavingId.
      for (final alloc in chargeAllocations) {
        await db.into(db.creditCardChargePaymentTable).insert(
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

        final charge = await (db.select(db.creditCardChargeTable)
              ..where((t) => t.id.equals(alloc.chargeId)))
            .getSingleOrNull();
        final deductFrom = charge?.reservedSavingId ?? sourceSavingId;
        await _adjustSavingBalance(deductFrom, -alloc.amount, now);
      }
    } else {
      // No per-charge allocations — deduct full amount from sourceSavingId.
      await _adjustSavingBalance(sourceSavingId, -amount, now);
    }

    // Rebate-covered allocations: create rows so getUnpaidAmount is reduced,
    // but intentionally skip any saving balance adjustment.
    if (rebateAllocations != null && rebateAllocations.isNotEmpty) {
      for (final alloc in rebateAllocations) {
        await db.into(db.creditCardChargePaymentTable).insert(
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
        // No _adjustSavingBalance — rebate credit, not real cash.
      }
    }
  }

  Future<void> _adjustSavingBalance(
    String savingId,
    double delta,
    DateTime now,
  ) async {
    final saving = await (db.select(db.savingTable)
          ..where((t) => t.id.equals(savingId)))
        .getSingleOrNull();
    if (saving == null) return;
    await (db.update(db.savingTable)..where((t) => t.id.equals(savingId)))
        .write(
          SavingTableCompanion(
            currentAmount: Value(saving.currentAmount + delta),
            dateUpdated: Value(now),
            lastModifiedBy: const Value('app'),
          ),
        );
  }

  @override
  Future<List<CrdCardChargePayment>> getPaymentAllocations(String paymentId) {
    return (db.select(db.creditCardChargePaymentTable)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();
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
