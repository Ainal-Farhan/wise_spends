import 'package:equatable/equatable.dart';

abstract class LoanListEvent extends Equatable {
  const LoanListEvent();

  @override
  List<Object?> get props => [];
}

class LoadLoansEvent extends LoanListEvent {}

class AddLoanEvent extends LoanListEvent {
  final String borrowerName;
  final double principalAmount;
  final DateTime loanDate;
  final DateTime? dueDate;
  final String sourceSavingId;
  final String? note;

  const AddLoanEvent({
    required this.borrowerName,
    required this.principalAmount,
    required this.loanDate,
    this.dueDate,
    required this.sourceSavingId,
    this.note,
  });

  @override
  List<Object?> get props => [
    borrowerName,
    principalAmount,
    loanDate,
    dueDate,
    sourceSavingId,
    note,
  ];
}

class DeleteLoanEvent extends LoanListEvent {
  final String id;

  const DeleteLoanEvent(this.id);

  @override
  List<Object?> get props => [id];
}
