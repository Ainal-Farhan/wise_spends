import 'package:equatable/equatable.dart';

abstract class LendingDetailEvent extends Equatable {
  const LendingDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadLendingDetailEvent extends LendingDetailEvent {
  final String lendingId;

  const LoadLendingDetailEvent(this.lendingId);

  @override
  List<Object?> get props => [lendingId];
}

class AddLendingRepaymentEvent extends LendingDetailEvent {
  final String lendingId;
  final double amount;
  final String destinationSavingId;
  final DateTime repaymentDate;
  final String? note;

  const AddLendingRepaymentEvent({
    required this.lendingId,
    required this.amount,
    required this.destinationSavingId,
    required this.repaymentDate,
    this.note,
  });

  @override
  List<Object?> get props => [
    lendingId,
    amount,
    destinationSavingId,
    repaymentDate,
    note,
  ];
}

class SettleLendingEvent extends LendingDetailEvent {
  final String id;

  const SettleLendingEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class UpdateLendingEvent extends LendingDetailEvent {
  final String lendingId;
  final String borrowerName;
  final double principalAmount;
  final DateTime lendingDate;
  final DateTime? dueDate;
  final String? note;
  final bool noAutoDeduct;

  const UpdateLendingEvent({
    required this.lendingId,
    required this.borrowerName,
    required this.principalAmount,
    required this.lendingDate,
    this.dueDate,
    this.note,
    this.noAutoDeduct = false,
  });

  @override
  List<Object?> get props => [
    lendingId,
    borrowerName,
    principalAmount,
    lendingDate,
    dueDate,
    note,
    noAutoDeduct,
  ];
}
