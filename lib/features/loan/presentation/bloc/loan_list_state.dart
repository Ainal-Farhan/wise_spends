import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

class LoanSummary {
  final LoanLoan loan;
  final double outstanding;

  const LoanSummary({required this.loan, required this.outstanding});
}

abstract class LoanListState extends Equatable {
  const LoanListState();

  @override
  List<Object?> get props => [];
}

class LoanListLoading extends LoanListState {}

class LoanListLoaded extends LoanListState {
  final List<LoanSummary> summaries;

  const LoanListLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

class LoanError extends LoanListState {
  final String message;

  const LoanError(this.message);

  @override
  List<Object?> get props => [message];
}
