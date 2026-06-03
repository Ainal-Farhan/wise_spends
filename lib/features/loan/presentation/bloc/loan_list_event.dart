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
  /// Empty string when [noAutoDeduct] is true.
  final String sourceSavingId;
  final String? note;
  final bool noAutoDeduct;

  const AddLoanEvent({
    required this.borrowerName,
    required this.principalAmount,
    required this.loanDate,
    this.dueDate,
    this.sourceSavingId = '',
    this.note,
    this.noAutoDeduct = false,
  });

  @override
  List<Object?> get props => [
    borrowerName,
    principalAmount,
    loanDate,
    dueDate,
    sourceSavingId,
    note,
    noAutoDeduct,
  ];
}

class DeleteLoanEvent extends LoanListEvent {
  final String id;

  const DeleteLoanEvent(this.id);

  @override
  List<Object?> get props => [id];
}
