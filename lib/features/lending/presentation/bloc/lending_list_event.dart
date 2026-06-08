import 'package:equatable/equatable.dart';

abstract class LendingListEvent extends Equatable {
  const LendingListEvent();

  @override
  List<Object?> get props => [];
}

class LoadLendingsEvent extends LendingListEvent {}

class AddLendingEvent extends LendingListEvent {
  final String borrowerName;
  final double principalAmount;
  final DateTime lendingDate;
  final DateTime? dueDate;
  final String sourceSavingId;
  final String? note;
  final bool noAutoDeduct;

  const AddLendingEvent({
    required this.borrowerName,
    required this.principalAmount,
    required this.lendingDate,
    this.dueDate,
    this.sourceSavingId = '',
    this.note,
    this.noAutoDeduct = false,
  });

  @override
  List<Object?> get props => [
    borrowerName,
    principalAmount,
    lendingDate,
    dueDate,
    sourceSavingId,
    note,
    noAutoDeduct,
  ];
}

class DeleteLendingEvent extends LendingListEvent {
  final String id;

  const DeleteLendingEvent(this.id);

  @override
  List<Object?> get props => [id];
}
