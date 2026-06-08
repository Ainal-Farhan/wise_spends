import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/data/db/domain/credit_card/credit_card_table.dart';
import 'package:wise_spends/data/repositories/i_crud_repository.dart';

abstract class ICreditCardRepository
    extends
        ICrudRepository<
          CreditCardTable,
          $CreditCardTableTable,
          CreditCardTableCompanion,
          CrdCardCreditCard
        > {
  ICreditCardRepository(AppDatabase db) : super(db, db.creditCardTable);

  Future<List<CrdCardCreditCard>> getAllCards();
  Future<CrdCardCreditCard?> getCardById(String id);
  Future<void> addCard({
    required String name,
    String? lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    String? note,
    String cardType,
    String? providerName,
  });
  Future<void> updateCard({
    required String id,
    required String name,
    String? lastFourDigits,
    required double creditLimit,
    required int statementDay,
    required int dueDay,
    String? note,
  });
  Future<void> deleteCard(String id);

  /// Deletes the card and all its charges/payments.
  /// For any charge with a [reservedSavingId] that still has an unpaid amount,
  /// the unpaid portion is returned to that saving account before deletion.
  Future<void> deleteCardWithCleanup(String id);
  Future<double> getTotalDebt(String cardId);
  Future<double> getAvailableCredit(String cardId);
}
