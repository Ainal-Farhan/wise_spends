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
    /// 'posted' (default) or 'pending'
    String status,
    /// True for cashback/rebate entries that reduce total debt.
    bool isRebate,
  });
  Future<void> deleteCharge(String id);
  /// Promotes a pending charge to 'posted' (or any [newStatus]).
  Future<void> updateChargeStatus(String chargeId, String newStatus);
  Future<double> getTotalUnpaid(String cardId);
  Future<double> getUnpaidAmount(String chargeId);
}
