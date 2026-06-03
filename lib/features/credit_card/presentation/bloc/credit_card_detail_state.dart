import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

abstract class CreditCardDetailState extends Equatable {
  const CreditCardDetailState();

  @override
  List<Object?> get props => [];
}

class CreditCardDetailLoading extends CreditCardDetailState {}

class CreditCardDetailLoaded extends CreditCardDetailState {
  final CrdCardCreditCard card;
  final List<CrdCardCharge> charges;
  final List<CrdCardPayment> payments;
  final double totalDebt;

  const CreditCardDetailLoaded({
    required this.card,
    required this.charges,
    required this.payments,
    required this.totalDebt,
  });

  @override
  List<Object?> get props => [card, charges, payments, totalDebt];
}

class CreditCardDetailError extends CreditCardDetailState {
  final String message;

  const CreditCardDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
