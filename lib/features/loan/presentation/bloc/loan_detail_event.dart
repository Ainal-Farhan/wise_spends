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

class UpdateLoanEvent extends LoanDetailEvent {
  final String loanId;
  final String borrowerName;
  final double principalAmount;
  final DateTime loanDate;
  final DateTime? dueDate;
  final String? note;
  final bool noAutoDeduct;

  const UpdateLoanEvent({
    required this.loanId,
    required this.borrowerName,
    required this.principalAmount,
    required this.loanDate,
    this.dueDate,
    this.note,
    this.noAutoDeduct = false,
  });

  @override
  List<Object?> get props => [
    loanId,
    borrowerName,
    principalAmount,
    loanDate,
    dueDate,
    note,
    noAutoDeduct,
  ];
}
