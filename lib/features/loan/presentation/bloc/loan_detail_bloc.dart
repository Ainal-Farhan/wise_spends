import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repository.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repayment_repository.dart';
import 'loan_detail_event.dart';
import 'loan_detail_state.dart';

class LoanDetailBloc extends Bloc<LoanDetailEvent, LoanDetailState> {
  final ILoanRepository _loanRepo;
  final ILoanRepaymentRepository _repaymentRepo;

  LoanDetailBloc(this._loanRepo, this._repaymentRepo)
    : super(LoanDetailLoading()) {
    on<LoadLoanDetailEvent>(_onLoad);
    on<AddRepaymentEvent>(_onAddRepayment);
    on<SettleLoanEvent>(_onSettle);
  }

  Future<void> _onLoad(
    LoadLoanDetailEvent event,
    Emitter<LoanDetailState> emit,
  ) async {
    emit(LoanDetailLoading());
    try {
      final loan = await _loanRepo.getLoanById(event.loanId);
      if (loan == null) {
        emit(const LoanDetailError('Loan not found'));
        return;
      }
      final repayments =
          await _repaymentRepo.getRepaymentsForLoan(event.loanId);
      final outstanding = await _loanRepo.getOutstandingAmount(event.loanId);
      emit(LoanDetailLoaded(
        loan: loan,
        repayments: repayments,
        outstanding: outstanding,
      ));
    } catch (e) {
      emit(LoanDetailError(e.toString()));
    }
  }

  Future<void> _onAddRepayment(
    AddRepaymentEvent event,
    Emitter<LoanDetailState> emit,
  ) async {
    try {
      await _repaymentRepo.addRepayment(
        loanId: event.loanId,
        amount: event.amount,
        destinationSavingId: event.destinationSavingId,
        repaymentDate: event.repaymentDate,
        note: event.note,
      );
      add(LoadLoanDetailEvent(event.loanId));
    } catch (e) {
      emit(LoanDetailError(e.toString()));
    }
  }

  Future<void> _onSettle(
    SettleLoanEvent event,
    Emitter<LoanDetailState> emit,
  ) async {
    try {
      await _loanRepo.settleLoan(event.id);
      add(LoadLoanDetailEvent(event.id));
    } catch (e) {
      emit(LoanDetailError(e.toString()));
    }
  }
}
