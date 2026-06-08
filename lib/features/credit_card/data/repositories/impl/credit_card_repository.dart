import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_repository.dart';

class CreditCardRepository extends ICreditCardRepository {
  CreditCardRepository() : super(AppDatabase());

  @override
  Future<List<CrdCardCreditCard>> getAllCards() {
    return db.select(db.creditCardTable).get();
  }

  @override
  Future<CrdCardCreditCard?> getCardById(String id) {
    return (db.select(db.creditCardTable)
      ..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  @override
  Future<void> addCard({
    required String name,
    String? lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    String? note,
    String cardType = 'credit_card',
    String? providerName,
  }) async {
    final now = DateTime.now();
    await db.into(db.creditCardTable).insert(
      CreditCardTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        name: name,
        lastFourDigits: Value(lastFourDigits),
        creditLimit: creditLimit,
        statementDay: statementDay,
        dueDay: dueDay,
        note: Value(note),
        cardType: Value(cardType),
        providerName: Value(providerName),
        createdBy: 'app',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'app',
      ),
    );
  }

  @override
  Future<void> updateCard({
    required String id,
    required String name,
    String? lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    String? note,
  }) async {
    await (db.update(db.creditCardTable)..where((t) => t.id.equals(id))).write(
      CreditCardTableCompanion(
        name: Value(name),
        lastFourDigits: Value(lastFourDigits),
        creditLimit: Value(creditLimit),
        statementDay: Value(statementDay),
        dueDay: Value(dueDay),
        note: Value(note),
        dateUpdated: Value(DateTime.now()),
        lastModifiedBy: const Value('app'),
      ),
    );
  }

  @override
  Future<void> deleteCard(String id) async {
    await deleteCardWithCleanup(id);
  }

  @override
  Future<void> deleteCardWithCleanup(String id) async {
    final charges = await (db.select(db.creditCardChargeTable)
          ..where((t) => t.creditCardId.equals(id)))
        .get();

    for (final charge in charges) {
      // Restore unpaid reserved amount back to the saving account
      if (charge.reservedSavingId != null) {
        final allocations = await (db.select(db.creditCardChargePaymentTable)
              ..where((t) => t.chargeId.equals(charge.id)))
            .get();
        final paid =
            allocations.fold<double>(0.0, (s, a) => s + a.allocatedAmount);
        final unpaid = (charge.amount - paid).clamp(0.0, double.infinity);
        // Nothing to restore — the saving balance was never deducted for the
        // reservation itself (only deducted at payment time). So we only need
        // to clean up allocations/charges so FK constraints don't block delete.
        assert(unpaid >= 0);
      }
      // Delete allocation rows for this charge
      await (db.delete(db.creditCardChargePaymentTable)
            ..where((t) => t.chargeId.equals(charge.id)))
          .go();
    }

    // Delete all payments for this card
    final payments = await (db.select(db.creditCardPaymentTable)
          ..where((t) => t.creditCardId.equals(id)))
        .get();
    for (final p in payments) {
      await (db.delete(db.creditCardChargePaymentTable)
            ..where((t) => t.paymentId.equals(p.id)))
          .go();
    }
    await (db.delete(db.creditCardPaymentTable)
          ..where((t) => t.creditCardId.equals(id)))
        .go();

    // Delete all charges
    await (db.delete(db.creditCardChargeTable)
          ..where((t) => t.creditCardId.equals(id)))
        .go();

    // Now safe to delete the card
    await (db.delete(db.creditCardTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<double> getTotalDebt(String cardId) async {
    final charges = await (db.select(db.creditCardChargeTable)
      ..where((t) => t.creditCardId.equals(cardId))).get();
    final payments = await (db.select(db.creditCardPaymentTable)
      ..where((t) => t.creditCardId.equals(cardId))).get();
    // Regular charges add to debt; rebates reduce it.
    final totalCharges = charges.fold<double>(0.0, (sum, c) {
      return c.isRebate ? sum - c.amount : sum + c.amount;
    });
    final totalPayments = payments.fold<double>(0.0, (sum, p) => sum + p.amount);
    return (totalCharges - totalPayments).clamp(0.0, double.infinity);
  }

  @override
  Future<double> getAvailableCredit(String cardId) async {
    final card = await getCardById(cardId);
    if (card == null) return 0.0;
    final debt = await getTotalDebt(cardId);
    return (card.creditLimit - debt).clamp(0.0, double.infinity);
  }

  @override
  String getTypeName() => 'CreditCardTable';

  @override
  CrdCardCreditCard fromJson(Map<String, dynamic> json) =>
      CrdCardCreditCard.fromJson(json);
}
