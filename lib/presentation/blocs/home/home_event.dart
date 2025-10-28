import 'package:equatable/equatable.dart';

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
  final String transactionType; // 'in', 'out', 'transfer'
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
      reference ?? ''
    ];
  }
}