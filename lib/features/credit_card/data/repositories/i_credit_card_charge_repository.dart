import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_charge_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICreditCardChargeRepository
    extends
        ICrudRepository<
          CreditCardChargeTable,
          $CreditCardChargeTableTable,
          CreditCardChargeTableCompanion,
          CrdCardCharge
        > {
  ICreditCardChargeRepository(AppDatabase db)
    : super(db, db.creditCardChargeTable);

  Future<List<CrdCardCharge>> getChargesForCard(String cardId);

  /// Returns charges for [cardId] on or after [since]. Pass null for all.
  Future<List<CrdCardCharge>> getChargesForCardSince(
      String cardId, DateTime? since);
  Future<void> addCharge({
    required String creditCardId,
    required String description,
    required double amount,
    String? categoryId,
    required DateTime chargeDate,
    String? note,
    String? reservedSavingId,
  });
  Future<void> deleteCharge(String id);
  Future<double> getTotalUnpaid(String cardId);
  Future<double> getUnpaidAmount(String chargeId);
}
