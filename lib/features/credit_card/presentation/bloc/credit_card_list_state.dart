import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';

class CreditCardSummary {
  final CrdCardCreditCard card;
  final double totalDebt;
  final double availableCredit;

  const CreditCardSummary({
    required this.card,
    required this.totalDebt,
    required this.availableCredit,
  });
}

abstract class CreditCardListState extends Equatable {
  const CreditCardListState();

  @override
  List<Object?> get props => [];
}

class CreditCardListLoading extends CreditCardListState {}

class CreditCardListLoaded extends CreditCardListState {
  final List<CreditCardSummary> summaries;

  const CreditCardListLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

class CreditCardError extends CreditCardListState {
  final String message;

  const CreditCardError(this.message);

  @override
  List<Object?> get props => [message];
}
