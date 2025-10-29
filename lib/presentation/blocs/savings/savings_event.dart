import 'package:equatable/equatable.dart';

abstract class SavingsEvent extends Equatable {
  const SavingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSavingsListEvent extends SavingsEvent {}

class LoadAddSavingsFormEvent extends SavingsEvent {}

class LoadEditSavingsEvent extends SavingsEvent {
  final String id;

  const LoadEditSavingsEvent(this.id);

  @override
  List<Object> get props => [id];
}

class LoadSavingTransactionEvent extends SavingsEvent {
  final String savingId;

  const LoadSavingTransactionEvent({required this.savingId});

  @override
  List<Object> get props => [savingId];
}

class AddSavingsEvent extends SavingsEvent {
  final String name;
  final double initialAmount;
  final bool isHasGoal;
  final double goalAmount;
  final String moneyStorageId;
  final String savingType;

  const AddSavingsEvent({
    required this.name,
    required this.initialAmount,
    required this.isHasGoal,
    required this.goalAmount,
    required this.moneyStorageId,
    required this.savingType,
  });

  @override
  List<Object> get props => [
    name,
    initialAmount,
    isHasGoal,
    goalAmount,
    moneyStorageId,
    savingType,
  ];
}

class UpdateSavingsEvent extends SavingsEvent {
  final String id;
  final String name;
  final double initialAmount;
  final bool isHasGoal;
  final double goalAmount;
  final String moneyStorageId;
  final String savingType;

  const UpdateSavingsEvent({
    required this.id,
    required this.name,
    required this.initialAmount,
    required this.isHasGoal,
    required this.goalAmount,
    required this.moneyStorageId,
    required this.savingType,
  });

  @override
  List<Object> get props => [
    id,
    name,
    initialAmount,
    isHasGoal,
    goalAmount,
    moneyStorageId,
    savingType,
  ];
}

class DeleteSavingEvent extends SavingsEvent {
  final String id;

  const DeleteSavingEvent(this.id);

  @override
  List<Object> get props => [id];
}
