import 'package:equatable/equatable.dart';

abstract class CreditCardListEvent extends Equatable {
  const CreditCardListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCreditCardsEvent extends CreditCardListEvent {}

class AddCreditCardEvent extends CreditCardListEvent {
  final String name;
  final String? lastFourDigits;
  final double creditLimit;
  final int statementDay;
  final int dueDay;
  final String? note;

  const AddCreditCardEvent({
    required this.name,
    this.lastFourDigits,
    required this.creditLimit,
    required this.statementDay,
    required this.dueDay,
    this.note,
  });

  @override
  List<Object?> get props => [
    name,
    lastFourDigits,
    creditLimit,
    statementDay,
    dueDay,
    note,
  ];
}

class DeleteCreditCardEvent extends CreditCardListEvent {
  final String id;

  const DeleteCreditCardEvent(this.id);

  @override
  List<Object?> get props => [id];
}
