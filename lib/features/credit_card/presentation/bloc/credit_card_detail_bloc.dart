import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_repository.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_charge_repository.dart';
import 'package:wise_spends/features/credit_card/data/repositories/i_credit_card_payment_repository.dart';
import 'credit_card_detail_event.dart';
import 'credit_card_detail_state.dart';

class CreditCardDetailBloc
    extends Bloc<CreditCardDetailEvent, CreditCardDetailState> {
  final ICreditCardRepository _cardRepo;
  final ICreditCardChargeRepository _chargeRepo;
  final ICreditCardPaymentRepository _paymentRepo;

  CreditCardDetailBloc(
    this._cardRepo,
    this._chargeRepo,
    this._paymentRepo,
  ) : super(CreditCardDetailLoading()) {
    on<LoadCreditCardDetailEvent>(_onLoad);
    on<AddChargeEvent>(_onAddCharge);
    on<AddPaymentEvent>(_onAddPayment);
    on<DeleteChargeEvent>(_onDeleteCharge);
  }

  Future<void> _onLoad(
    LoadCreditCardDetailEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    emit(CreditCardDetailLoading());
    try {
      final card = await _cardRepo.getCardById(event.cardId);
      if (card == null) {
        emit(const CreditCardDetailError('Card not found'));
        return;
      }
      final charges = await _chargeRepo.getChargesForCard(event.cardId);
      final payments = await _paymentRepo.getPaymentsForCard(event.cardId);
      final debt = await _cardRepo.getTotalDebt(event.cardId);
      emit(CreditCardDetailLoaded(
        card: card,
        charges: charges,
        payments: payments,
        totalDebt: debt,
      ));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }

  Future<void> _onAddCharge(
    AddChargeEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    try {
      await _chargeRepo.addCharge(
        creditCardId: event.creditCardId,
        description: event.description,
        amount: event.amount,
        categoryId: event.categoryId,
        chargeDate: event.chargeDate,
        note: event.note,
      );
      add(LoadCreditCardDetailEvent(event.creditCardId));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }

  Future<void> _onAddPayment(
    AddPaymentEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    try {
      await _paymentRepo.addPayment(
        creditCardId: event.creditCardId,
        sourceSavingId: event.sourceSavingId,
        amount: event.amount,
        paymentDate: event.paymentDate,
        note: event.note,
        chargeAllocations: event.chargeAllocations,
      );
      add(LoadCreditCardDetailEvent(event.creditCardId));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteCharge(
    DeleteChargeEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    final current = state;
    try {
      await _chargeRepo.deleteCharge(event.id);
      if (current is CreditCardDetailLoaded) {
        add(LoadCreditCardDetailEvent(current.card.id));
      }
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }
}
