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
    on<ConfirmChargeEvent>(_onConfirmCharge);
    on<UpdateCreditCardEvent>(_onUpdateCard);
    on<DeleteCreditCardDetailEvent>(_onDeleteCard);
    on<ChangePeriodEvent>(_onChangePeriod);
  }

  ChargePeriod _currentPeriod = ChargePeriod.days30;

  Future<void> _onLoad(
    LoadCreditCardDetailEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    emit(CreditCardDetailLoading());
    await _reload(event.cardId, emit);
  }

  Future<void> _onChangePeriod(
    ChangePeriodEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    final current = state;
    if (current is! CreditCardDetailLoaded) return;
    _currentPeriod = event.period;
    await _reload(current.card.id, emit, preserveLoading: false);
  }

  Future<void> _reload(
    String cardId,
    Emitter<CreditCardDetailState> emit, {
    bool preserveLoading = true,
  }) async {
    try {
      final card = await _cardRepo.getCardById(cardId);
      if (card == null) {
        emit(const CreditCardDetailError('Card not found'));
        return;
      }

      // All charges — needed for payment sheet and unpaid calculations
      final allCharges = await _chargeRepo.getChargesForCard(cardId);

      // Filtered charges/payments for display
      final since = _currentPeriod.since;
      final filteredCharges =
          await _chargeRepo.getChargesForCardSince(cardId, since);
      final filteredPayments =
          await _paymentRepo.getPaymentsForCardSince(cardId, since);

      final debt = await _cardRepo.getTotalDebt(cardId);

      // Per-charge unpaid amounts (always from ALL charges)
      final unpaidMap = <String, double>{};
      for (final c in allCharges) {
        unpaidMap[c.id] = await _chargeRepo.getUnpaidAmount(c.id);
      }

      // Per-payment allocation details (for the filtered payments)
      final allocationMap =
          <String, List<PaymentAllocationDetail>>{};
      for (final p in filteredPayments) {
        final rows = await _paymentRepo.getPaymentAllocations(p.id);
        final details = rows.map((row) {
          final charge = allCharges.firstWhere(
            (c) => c.id == row.chargeId,
            orElse: () => allCharges.first,
          );
          return PaymentAllocationDetail(
            chargeId: row.chargeId,
            chargeDescription:
                allCharges.any((c) => c.id == row.chargeId)
                    ? charge.description
                    : row.chargeId,
            allocatedAmount: row.allocatedAmount,
          );
        }).toList();
        if (details.isNotEmpty) allocationMap[p.id] = details;
      }

      emit(CreditCardDetailLoaded(
        card: card,
        charges: filteredCharges,
        allCharges: allCharges,
        payments: filteredPayments,
        totalDebt: debt,
        period: _currentPeriod,
        chargeUnpaidAmounts: unpaidMap,
        paymentAllocations: allocationMap,
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
        reservedSavingId: event.reservedSavingId,
        status: event.status,
        isRebate: event.isRebate,
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
        rebateAllocations: event.rebateAllocations,
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

  Future<void> _onConfirmCharge(
    ConfirmChargeEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    try {
      await _chargeRepo.updateChargeStatus(event.chargeId, 'posted');
      add(LoadCreditCardDetailEvent(event.cardId));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }

  Future<void> _onUpdateCard(
    UpdateCreditCardEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    try {
      await _cardRepo.updateCard(
        id: event.cardId,
        name: event.name,
        lastFourDigits: event.lastFourDigits,
        creditLimit: event.creditLimit,
        statementDay: event.statementDay,
        dueDay: event.dueDay,
        note: event.note,
      );
      add(LoadCreditCardDetailEvent(event.cardId));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }

  Future<void> _onDeleteCard(
    DeleteCreditCardDetailEvent event,
    Emitter<CreditCardDetailState> emit,
  ) async {
    try {
      await _cardRepo.deleteCardWithCleanup(event.cardId);
      emit(const CreditCardDetailError('deleted'));
    } catch (e) {
      emit(CreditCardDetailError(e.toString()));
    }
  }
}
