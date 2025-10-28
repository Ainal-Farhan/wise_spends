import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/impl/money_storage/money_storage_vo.dart';

abstract class MoneyStorageState extends Equatable {
  const MoneyStorageState();

  @override
  List<Object?> get props => [];
}

class MoneyStorageInitial extends MoneyStorageState {}

class MoneyStorageLoading extends MoneyStorageState {}

class MoneyStorageListLoaded extends MoneyStorageState {
  final List<MoneyStorageVO> moneyStorageList;

  const MoneyStorageListLoaded(this.moneyStorageList);

  @override
  List<Object> get props => [moneyStorageList];
}

class MoneyStorageFormLoaded extends MoneyStorageState {
  final bool isEditing;
  final MoneyStorageVO? moneyStorage;

  const MoneyStorageFormLoaded({
    required this.isEditing,
    this.moneyStorage,
  });

  @override
  List<Object?> get props => [isEditing, moneyStorage];
}

class MoneyStorageSuccess extends MoneyStorageState {
  final String message;

  const MoneyStorageSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class MoneyStorageError extends MoneyStorageState {
  final String message;

  const MoneyStorageError(this.message);

  @override
  List<Object> get props => [message];
}