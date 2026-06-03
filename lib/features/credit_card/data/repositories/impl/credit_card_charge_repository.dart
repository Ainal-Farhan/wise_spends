import 'package:drift/drift.dart';
import 'package:wise_spends/core/utils/uuid_generator.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_charge_repository.dart';

class CreditCardChargeRepository extends ICreditCardChargeRepository {
  CreditCardChargeRepository() : super(AppDatabase());

  @override
  Future<List<CrdCardCharge>> getChargesForCard(String cardId) {
    return (db.select(db.creditCardChargeTable)
      ..where((t) => t.creditCardId.equals(cardId))).get();
  }

  @override
  Future<void> addCharge({
    required String creditCardId,
    required String description,
    required double amount,
    String? categoryId,
    required DateTime chargeDate,
    String? note,
  }) async {
    final now = DateTime.now();
    await db.into(db.creditCardChargeTable).insert(
      CreditCardChargeTableCompanion.insert(
        id: Value(UuidGenerator().v4()),
        creditCardId: creditCardId,
        description: description,
        amount: amount,
        categoryId: Value(categoryId),
        chargeDate: chargeDate,
        note: Value(note),
        createdBy: 'app',
        dateCreated: Value(now),
        dateUpdated: now,
        lastModifiedBy: 'app',
      ),
    );
  }

  @override
  Future<void> deleteCharge(String id) async {
    await (db.delete(db.creditCardChargeTable)
      ..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<double> getTotalUnpaid(String cardId) async {
    final charges = await getChargesForCard(cardId);
    double total = 0;
    for (final charge in charges) {
      final allocations = await (db.select(db.creditCardChargePaymentTable)
        ..where((t) => t.chargeId.equals(charge.id))).get();
      final paid = allocations.fold<double>(0.0, (sum, a) => sum + a.allocatedAmount);
      total += (charge.amount - paid).clamp(0.0, double.infinity);
    }
    return total;
  }

  @override
  String getTypeName() => 'CreditCardChargeTable';

  @override
  CrdCardCharge fromJson(Map<String, dynamic> json) =>
      CrdCardCharge.fromJson(json);
}
