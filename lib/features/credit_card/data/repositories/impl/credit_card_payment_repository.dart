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
    List<({String rebateId, double amount})>? appliedRebates,
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
      // Cash allocations: deduct from each charge's reservedSavingId if set,
      // otherwise fall back to sourceSavingId.  Store deductedSavingId so
      // deletePayment can restore the correct account.
      for (final alloc in chargeAllocations) {
        final charge = await (db.select(db.creditCardChargeTable)
              ..where((t) => t.id.equals(alloc.chargeId)))
            .getSingleOrNull();
        final deductFrom = charge?.reservedSavingId ?? sourceSavingId;
        await db.into(db.creditCardChargePaymentTable).insert(
          CreditCardChargePaymentTableCompanion.insert(
            id: Value(UuidGenerator().v4()),
            chargeId: alloc.chargeId,
            paymentId: paymentId,
            allocatedAmount: alloc.amount,
            deductedSavingId: Value(deductFrom),
            createdBy: 'app',
            dateCreated: Value(now),
            dateUpdated: now,
            lastModifiedBy: 'app',
          ),
        );
        await _adjustSavingBalance(deductFrom, -alloc.amount, now);
      }
    } else {
      // No per-charge allocations — deduct full amount from sourceSavingId.
      await _adjustSavingBalance(sourceSavingId, -amount, now);
    }

    // Rebate-covered allocations: reduce the charge's unpaid amount but no
    // saving is touched.  deductedSavingId left null to mark as non-cash.
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
      }
    }

    // Consume each rebate charge by the exact amount used from it.
    // deductedSavingId left null — no cash movement for rebate consumption.
    if (appliedRebates != null && appliedRebates.isNotEmpty) {
      for (final r in appliedRebates) {
        if (r.amount <= 0) continue;
        await db.into(db.creditCardChargePaymentTable).insert(
          CreditCardChargePaymentTableCompanion.insert(
            id: Value(UuidGenerator().v4()),
            chargeId: r.rebateId,
            paymentId: paymentId,
            allocatedAmount: r.amount,
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
  Future<void> deletePayment(String paymentId) async {
    final payment = await (db.select(db.creditCardPaymentTable)
          ..where((t) => t.id.equals(paymentId)))
        .getSingleOrNull();
    if (payment == null) return;

    final now = DateTime.now();
    final allocations = await (db.select(db.creditCardChargePaymentTable)
          ..where((t) => t.paymentId.equals(paymentId)))
        .get();

    if (allocations.isNotEmpty) {
      // Restore saving balances for cash allocations only (deductedSavingId != null).
      // Group by saving account to batch the adjustments.
      final Map<String, double> restoreMap = {};
      for (final alloc in allocations) {
        final savingId = alloc.deductedSavingId;
        if (savingId == null) continue; // rebate row — no cash was moved
        restoreMap[savingId] = (restoreMap[savingId] ?? 0.0) + alloc.allocatedAmount;
      }
      for (final entry in restoreMap.entries) {
        await _adjustSavingBalance(entry.key, entry.value, now);
      }
    } else {
      // No allocation rows — the full payment amount came from sourceSavingId.
      await _adjustSavingBalance(payment.sourceSavingId, payment.amount, now);
    }

    // Remove allocation rows then the payment record.
    await (db.delete(db.creditCardChargePaymentTable)
          ..where((t) => t.paymentId.equals(paymentId)))
        .go();
    await (db.delete(db.creditCardPaymentTable)
          ..where((t) => t.id.equals(paymentId)))
        .go();
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
