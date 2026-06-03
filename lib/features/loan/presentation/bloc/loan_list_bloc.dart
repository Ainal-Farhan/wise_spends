import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/loan/data/repositories/i_loan_repository.dart';
import 'loan_list_event.dart';
import 'loan_list_state.dart';

class LoanListBloc extends Bloc<LoanListEvent, LoanListState> {
  final ILoanRepository _repository;

  LoanListBloc(this._repository) : super(LoanListLoading()) {
    on<LoadLoansEvent>(_onLoad);
    on<AddLoanEvent>(_onAdd);
    on<DeleteLoanEvent>(_onDelete);
  }

  Future<void> _onLoad(
    LoadLoansEvent event,
    Emitter<LoanListState> emit,
  ) async {
    emit(LoanListLoading());
    try {
      final loans = await _repository.getAllLoans();
      final summaries = await Future.wait(
        loans.map((loan) async {
          final outstanding = await _repository.getOutstandingAmount(loan.id);
          return LoanSummary(loan: loan, outstanding: outstanding);
        }),
      );
      emit(LoanListLoaded(summaries));
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onAdd(
    AddLoanEvent event,
    Emitter<LoanListState> emit,
  ) async {
    try {
      await _repository.addLoan(
        borrowerName: event.borrowerName,
        principalAmount: event.principalAmount,
        loanDate: event.loanDate,
        dueDate: event.dueDate,
        sourceSavingId: event.sourceSavingId,
        note: event.note,
      );
      add(LoadLoansEvent());
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }

  Future<void> _onDelete(
    DeleteLoanEvent event,
    Emitter<LoanListState> emit,
  ) async {
    try {
      await _repository.deleteLoan(event.id);
      add(LoadLoansEvent());
    } catch (e) {
      emit(LoanError(e.toString()));
    }
  }
}
