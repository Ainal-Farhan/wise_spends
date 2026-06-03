import 'package:equatable/equatable.dart';

abstract class LoanDetailEvent extends Equatable {
  const LoanDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoanDetailEvent extends LoanDetailEvent {
  final String loanId;

  const LoadLoanDetailEvent(this.loanId);

  @override
  List<Object?> get props => [loanId];
}

class AddRepaymentEvent extends LoanDetailEvent {
  final String loanId;
  final double amount;
  final String destinationSavingId;
  final DateTime repaymentDate;
  final String? note;

  const AddRepaymentEvent({
    required this.loanId,
    required this.amount,
    required this.destinationSavingId,
    required this.repaymentDate,
    this.note,
  });

  @override
  List<Object?> get props => [
    loanId,
    amount,
    destinationSavingId,
    repaymentDate,
    note,
  ];
}

class SettleLoanEvent extends LoanDetailEvent {
  final String id;

  const SettleLoanEvent(this.id);

  @override
  List<Object?> get props => [id];
}
