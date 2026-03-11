import 'package:equatable/equatable.dart';

abstract class MoneyStorageEvent extends Equatable {
  const MoneyStorageEvent();

  @override
  List<Object> get props => [];
}

class LoadMoneyStorageListEvent extends MoneyStorageEvent {}

class LoadAddMoneyStorageEvent extends MoneyStorageEvent {}

class LoadEditMoneyStorageEvent extends MoneyStorageEvent {
  final String id;

  const LoadEditMoneyStorageEvent(this.id);

  @override
  List<Object> get props => [id];
}

class AddMoneyStorageEvent extends MoneyStorageEvent {
  final String shortName;
  final String longName;

  const AddMoneyStorageEvent({required this.shortName, required this.longName});

  @override
  List<Object> get props => [shortName, longName];
}

class UpdateMoneyStorageEvent extends MoneyStorageEvent {
  final String id;
  final String shortName;
  final String longName;

  const UpdateMoneyStorageEvent({
    required this.id,
    required this.shortName,
    required this.longName,
  });

  @override
  List<Object> get props => [id, shortName, longName];
}

class DeleteMoneyStorageEvent extends MoneyStorageEvent {
  final String id;

  const DeleteMoneyStorageEvent(this.id);

  @override
  List<Object> get props => [id];
}
