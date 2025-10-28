import 'package:equatable/equatable.dart';
import 'package:wise_spends/data/db/app_database.dart';
import 'package:wise_spends/domain/entities/impl/saving/list_saving_vo.dart';

abstract class SavingsState extends Equatable {
  const SavingsState();

  @override
  List<Object?> get props => [];
}

class SavingsInitial extends SavingsState {}

class SavingsLoading extends SavingsState {}

class SavingsListLoaded extends SavingsState {
  final List<ListSavingVO> savingsList;

  const SavingsListLoaded(this.savingsList);

  @override
  List<Object> get props => [savingsList];
}

class SavingsFormLoaded extends SavingsState {
  final bool isEditing;
  final ListSavingVO? saving;
  final List<SvngMoneyStorage> moneyStorageOptions;

  const SavingsFormLoaded({
    required this.isEditing,
    this.saving,
    required this.moneyStorageOptions,
  });

  @override
  List<Object?> get props => [isEditing, saving, moneyStorageOptions];
}

class SavingTransactionFormLoaded extends SavingsState {
  final String savingId;

  const SavingTransactionFormLoaded(this.savingId);

  @override
  List<Object> get props => [savingId];
}

class MoneyStorageOptionsLoaded extends SavingsState {
  final List<SvngMoneyStorage> moneyStorageOptions;

  const MoneyStorageOptionsLoaded(this.moneyStorageOptions);

  @override
  List<Object> get props => [moneyStorageOptions];
}

class SavingsSuccess extends SavingsState {
  final String message;

  const SavingsSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class SavingsError extends SavingsState {
  final String message;

  const SavingsError(this.message);

  @override
  List<Object> get props => [message];
}
