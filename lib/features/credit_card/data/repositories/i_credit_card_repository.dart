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
  Future<double> getTotalDebt(String cardId);
  Future<double> getAvailableCredit(String cardId);
}
