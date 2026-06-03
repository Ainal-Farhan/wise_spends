import 'package:equatable/equatable.dart';

/// How far back to show charges/payments in the detail view.
enum ChargePeriod {
  days30,
  days60,
  days90,
  all;

  int? get days => switch (this) {
        ChargePeriod.days30 => 30,
        ChargePeriod.days60 => 60,
        ChargePeriod.days90 => 90,
        ChargePeriod.all => null,
      };

  String get label => switch (this) {
        ChargePeriod.days30 => '30d',
        ChargePeriod.days60 => '60d',
        ChargePeriod.days90 => '90d',
        ChargePeriod.all => 'All',
      };

  DateTime? get since {
    final d = days;
    if (d == null) return null;
    return DateTime.now().subtract(Duration(days: d));
  }
}

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
  final String? reservedSavingId;
  /// 'posted' (default) or 'pending'
  final String status;
  final bool isRebate;

  const AddChargeEvent({
    required this.creditCardId,
    required this.description,
    required this.amount,
    this.categoryId,
    required this.chargeDate,
    this.note,
    this.reservedSavingId,
    this.status = 'posted',
    this.isRebate = false,
  });

  @override
  List<Object?> get props => [
    creditCardId,
    description,
    amount,
    categoryId,
    chargeDate,
    note,
    reservedSavingId,
    status,
    isRebate,
  ];
}

class AddPaymentEvent extends CreditCardDetailEvent {
  final String creditCardId;
  final String sourceSavingId;
  final double amount;
  final DateTime paymentDate;
  final String? note;
  final List<({String chargeId, double amount})>? chargeAllocations;
  /// Portions covered by rebate credits — no saving deduction.
  final List<({String chargeId, double amount})>? rebateAllocations;

  const AddPaymentEvent({
    required this.creditCardId,
    required this.sourceSavingId,
    required this.amount,
    required this.paymentDate,
    this.note,
    this.chargeAllocations,
    this.rebateAllocations,
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

class ConfirmChargeEvent extends CreditCardDetailEvent {
  final String chargeId;
  final String cardId;

  const ConfirmChargeEvent({required this.chargeId, required this.cardId});

  @override
  List<Object?> get props => [chargeId, cardId];
}

class UpdateCreditCardEvent extends CreditCardDetailEvent {
  final String cardId;
  final String name;
  final String? lastFourDigits;
  final double creditLimit;
  final int statementDay;
  final int dueDay;
  final String? note;

  const UpdateCreditCardEvent({
    required this.cardId,
    required this.name,
    this.lastFourDigits,
    required this.creditLimit,
    required this.statementDay,
    required this.dueDay,
    this.note,
  });

  @override
  List<Object?> get props =>
      [cardId, name, lastFourDigits, creditLimit, statementDay, dueDay, note];
}

class DeleteCreditCardDetailEvent extends CreditCardDetailEvent {
  final String cardId;

  const DeleteCreditCardDetailEvent(this.cardId);

  @override
  List<Object?> get props => [cardId];
}

class ChangePeriodEvent extends CreditCardDetailEvent {
  final ChargePeriod period;

  const ChangePeriodEvent(this.period);

  @override
  List<Object?> get props => [period];
}
