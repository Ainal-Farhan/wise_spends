import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/lending/data/repositories/i_lending_repository.dart';
import 'package:wise_spends/features/lending/data/repositories/i_lending_repayment_repository.dart';
import 'lending_detail_event.dart';
import 'lending_detail_state.dart';

class LendingDetailBloc extends Bloc<LendingDetailEvent, LendingDetailState> {
  final ILendingRepository _lendingRepo;
  final ILendingRepaymentRepository _repaymentRepo;

  LendingDetailBloc(this._lendingRepo, this._repaymentRepo)
    : super(LendingDetailLoading()) {
    on<LoadLendingDetailEvent>(_onLoad);
    on<AddLendingRepaymentEvent>(_onAddRepayment);
    on<SettleLendingEvent>(_onSettle);
    on<UpdateLendingEvent>(_onUpdate);
  }

  Future<void> _onLoad(
    LoadLendingDetailEvent event,
    Emitter<LendingDetailState> emit,
  ) async {
    emit(LendingDetailLoading());
    try {
      final lending = await _lendingRepo.getLendingById(event.lendingId);
      if (lending == null) {
        emit(const LendingDetailError('Lending record not found'));
        return;
      }
      final repayments = await _repaymentRepo.getRepaymentsForLending(
        event.lendingId,
      );
      final outstanding =
          await _lendingRepo.getOutstandingAmount(event.lendingId);
      emit(
        LendingDetailLoaded(
          lending: lending,
          repayments: repayments,
          outstanding: outstanding,
        ),
      );
    } catch (e) {
      emit(LendingDetailError(e.toString()));
    }
  }

  Future<void> _onAddRepayment(
    AddLendingRepaymentEvent event,
    Emitter<LendingDetailState> emit,
  ) async {
    try {
      await _repaymentRepo.addRepayment(
        lendingId: event.lendingId,
        amount: event.amount,
        destinationSavingId: event.destinationSavingId,
        repaymentDate: event.repaymentDate,
        note: event.note,
      );
      add(LoadLendingDetailEvent(event.lendingId));
    } catch (e) {
      emit(LendingDetailError(e.toString()));
    }
  }

  Future<void> _onSettle(
    SettleLendingEvent event,
    Emitter<LendingDetailState> emit,
  ) async {
    try {
      await _lendingRepo.settleLending(event.id);
      add(LoadLendingDetailEvent(event.id));
    } catch (e) {
      emit(LendingDetailError(e.toString()));
    }
  }

  Future<void> _onUpdate(
    UpdateLendingEvent event,
    Emitter<LendingDetailState> emit,
  ) async {
    try {
      await _lendingRepo.updateLending(
        id: event.lendingId,
        borrowerName: event.borrowerName,
        principalAmount: event.principalAmount,
        lendingDate: event.lendingDate,
        dueDate: event.dueDate,
        note: event.note,
        noAutoDeduct: event.noAutoDeduct,
      );
      add(LoadLendingDetailEvent(event.lendingId));
    } catch (e) {
      emit(LendingDetailError(e.toString()));
    }
  }
}
