import 'package:equatable/equatable.dart';

abstract class CreditCardDetailEvent extends Equatable {
  const CreditCardDetailEvent();

  @override
  List<Object?> get props => [];
}

class LoadCreditCardDetailEvent extends CreditCardDetailEvent {
  final String cardId;

  const LoadCreditCardDetailEvent(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class AddChargeEvent extends CreditCardDetailEvent {
  final String creditCardId;
  final String description;
  final double amount;
  final String? categoryId;
  final DateTime chargeDate;
  final String? note;

  const AddChargeEvent({
    required this.creditCardId,
    required this.description,
    required this.amount,
    this.categoryId,
    required this.chargeDate,
    this.note,
  });

  @override
  List<Object?> get props => [
    creditCardId,
    description,
    amount,
    categoryId,
    chargeDate,
    note,
  ];
}

class AddPaymentEvent extends CreditCardDetailEvent {
  final String creditCardId;
  final String sourceSavingId;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final List<({String chargeId, double amount})>? chargeAllocations;

  const AddPaymentEvent({
    required this.creditCardId,
    required this.sourceSavingId,
    required this.amount,
    required this.paymentDate,
    this.note,
    this.chargeAllocations,
  });

  @override
  List<Object?> get props => [
    creditCardId,
    sourceSavingId,
    amount,
    paymentDate,
    note,
  ];
}

class DeleteChargeEvent extends CreditCardDetailEvent {
  final String id;

  const DeleteChargeEvent(this.id);

  @override
  List<Object?> get props => [id];
}
