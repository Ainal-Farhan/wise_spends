import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class LoadHomeDataEvent extends HomeEvent {}

class LoadTransactionFormEvent extends HomeEvent {}

class MakeTransactionEvent extends HomeEvent {
  final String sourceSavingId;
  final String? destinationSavingId;
  final double amount;
  final TransactionType transactionType;
  final String? reference;

  const MakeTransactionEvent({
    required this.sourceSavingId,
    this.destinationSavingId,
    required this.amount,
    required this.transactionType,
    this.reference,
  });

  @override
  List<Object> get props {
    return [
      sourceSavingId,
      destinationSavingId ?? '',
      amount,
      transactionType,
      reference ?? '',
    ];
  }
}
