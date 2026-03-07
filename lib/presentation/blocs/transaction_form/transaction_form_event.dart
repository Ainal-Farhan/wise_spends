import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/impl/commitment/commitment_task_vo.dart';
import 'package:wise_spends/domain/entities/impl/expense/payee_vo.dart';
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

/// Initialize form for editing existing transaction
class InitializeTransactionFormForEdit extends TransactionFormEvent {
  final TransactionEntity transaction;
  final CommitmentTaskVO? commitmentTaskVO;
  final CategoryEntity? category;
  final TimeOfDay? selectedTime;
  final PayeeVO? payee;

  const InitializeTransactionFormForEdit({
    required this.transaction,
    this.category,
    this.selectedTime,
    this.payee,
    this.commitmentTaskVO,
  });

  @override
  List<Object?> get props => [transaction, category, selectedTime, payee];
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

class SelectPayee extends TransactionFormEvent {
  final PayeeVO? payee; // null = cleared
  const SelectPayee(this.payee);
}

/// Change date
class ChangeTransactionDate extends TransactionFormEvent {
  final DateTime date;

  const ChangeTransactionDate(this.date);

  @override
  List<Object?> get props => [date];
}

/// Change time
class ChangeTransactionTime extends TransactionFormEvent {
  final TimeOfDay time;

  const ChangeTransactionTime(this.time);

  @override
  List<Object?> get props => [time];
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
