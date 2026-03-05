import 'package:equatable/equatable.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

/// Transaction Form BLoC Events
abstract class TransactionFormEvent extends Equatable {
  const TransactionFormEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize form with preselected type
class InitializeTransactionForm extends TransactionFormEvent {
  final TransactionType? preselectedType;

  const InitializeTransactionForm({this.preselectedType});

  @override
  List<Object?> get props => [preselectedType];
}

/// Change transaction type
class ChangeTransactionType extends TransactionFormEvent {
  final TransactionType type;

  const ChangeTransactionType(this.type);

  @override
  List<Object?> get props => [type];
}

/// Select category
class SelectCategory extends TransactionFormEvent {
  final CategoryEntity? category;

  const SelectCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Change date
class ChangeTransactionDate extends TransactionFormEvent {
  final DateTime date;

  const ChangeTransactionDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Toggle note field visibility
class ToggleNoteField extends TransactionFormEvent {
  final bool show;

  const ToggleNoteField(this.show);

  @override
  List<Object?> get props => [show];
}

/// Select source account
class SelectSourceAccount extends TransactionFormEvent {
  final String? accountId;

  const SelectSourceAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Select destination account
class SelectDestinationAccount extends TransactionFormEvent {
  final String? accountId;

  const SelectDestinationAccount(this.accountId);

  @override
  List<Object?> get props => [accountId];
}

/// Clear form
class ClearTransactionForm extends TransactionFormEvent {}
