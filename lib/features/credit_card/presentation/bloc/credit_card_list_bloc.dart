import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_repository.dart';
import 'credit_card_list_event.dart';
import 'credit_card_list_state.dart';

class CreditCardListBloc
    extends Bloc<CreditCardListEvent, CreditCardListState> {
  final ICreditCardRepository _repository;

  CreditCardListBloc(this._repository) : super(CreditCardListLoading()) {
    on<LoadCreditCardsEvent>(_onLoad);
    on<AddCreditCardEvent>(_onAdd);
    on<DeleteCreditCardEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadCreditCardsEvent event,
    Emitter<CreditCardListState> emit,
  ) async {
    emit(CreditCardListLoading());
    try {
      final cards = await _repository.getAllCards();
      final summaries = await Future.wait(
        cards.map((card) async {
          final debt = await _repository.getTotalDebt(card.id);
          final available = await _repository.getAvailableCredit(card.id);
          return CreditCardSummary(
            card: card,
            totalDebt: debt,
            availableCredit: available,
          );
        }),
      );
      emit(CreditCardListLoaded(summaries));
    } catch (e) {
      emit(CreditCardError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddCreditCardEvent event,
    Emitter<CreditCardListState> emit,
  ) async {
    try {
      await _repository.addCard(
        name: event.name,
        lastFourDigits: event.lastFourDigits,
        creditLimit: event.creditLimit,
        statementDay: event.statementDay,
        dueDay: event.dueDay,
        note: event.note,
        cardType: event.cardType,
        providerName: event.providerName,
      );
      add(LoadCreditCardsEvent());
    } catch (e) {
      emit(CreditCardError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteCreditCardEvent event,
    Emitter<CreditCardListState> emit,
  ) async {
    try {
      await _repository.deleteCard(event.id);
      add(LoadCreditCardsEvent());
    } catch (e) {
      emit(CreditCardError(e.toString()));
    }
  }
}
