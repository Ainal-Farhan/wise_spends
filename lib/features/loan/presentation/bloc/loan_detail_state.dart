import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

abstract class LoanDetailState extends Equatable {
  const LoanDetailState();

  @override
  List<Object?> get props => [];
}

class LoanDetailLoading extends LoanDetailState {}

class LoanDetailLoaded extends LoanDetailState {
  final LoanLoan loan;
  final List<LoanRepayment> repayments;
  final double outstanding;

  const LoanDetailLoaded({
    required this.loan,
    required this.repayments,
    required this.outstanding,
  });

  @override
  List<Object?> get props => [loan, repayments, outstanding];
}

class LoanDetailError extends LoanDetailState {
  final String message;

  const LoanDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
