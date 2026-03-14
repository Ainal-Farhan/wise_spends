import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/features/commitment/data/constants/commitment_task_type.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/payee/domain/entities/payee_vo.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

/// Transaction Form BLoC States
abstract class TransactionFormState extends Equatable {
  const TransactionFormState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class TransactionFormInitial extends TransactionFormState {}

/// Form loading state
class TransactionFormLoading extends TransactionFormState {}

/// Form ready state
class TransactionFormReady extends TransactionFormState {
  final TransactionType transactionType;
  final CategoryEntity? selectedCategory;
  final CommitmentTaskType? commitmentTaskType;
  final PayeeVO? selectedPayee;
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final bool showNoteField;
  final String? selectedSourceAccount;
  final String? selectedDestinationAccount;

  // Edit-mode only fields
  final String? title;
  final String? amount;
  final String? note;
  final bool isEditMode;
  final String? editingTransactionId;

  TransactionFormReady({
    this.transactionType = TransactionType.expense,
    this.selectedCategory,
    this.selectedPayee,
    DateTime? selectedDate,
    this.commitmentTaskType,
    this.selectedTime,
    this.showNoteField = false,
    this.selectedSourceAccount,
    this.selectedDestinationAccount,
    this.title,
    this.amount,
    this.note,
    this.isEditMode = false,
    this.editingTransactionId,
  }) : selectedDate = selectedDate ?? DateTime.now();

  /// Whether this transaction type supports payee selection.
  bool get supportsPayee =>
      transactionType == TransactionType.expense ||
      (transactionType == TransactionType.commitment &&
          (selectedPayee != null ||
              (commitmentTaskType != null &&
                  CommitmentTaskType.thirdPartyPayment == commitmentTaskType)));

  TransactionFormReady copyWith({
    TransactionType? transactionType,
    CategoryEntity? selectedCategory,
    CommitmentTaskType? commitmentTaskType,
    bool clearCategory = false,
    PayeeVO? selectedPayee,
    bool clearPayee = false,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    bool? showNoteField,
    String? selectedSourceAccount,
    String? selectedDestinationAccount,
    String? title,
    String? amount,
    String? note,
    bool? isEditMode,
    String? editingTransactionId,
    final bool clearTime = false,
  }) {
    return TransactionFormReady(
      transactionType: transactionType ?? this.transactionType,
      selectedCategory: clearCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      commitmentTaskType: commitmentTaskType,
      selectedPayee: clearPayee ? null : (selectedPayee ?? this.selectedPayee),
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: clearTime ? null : (selectedTime ?? this.selectedTime),
      showNoteField: showNoteField ?? this.showNoteField,
      selectedSourceAccount:
          selectedSourceAccount ?? this.selectedSourceAccount,
      selectedDestinationAccount:
          selectedDestinationAccount ?? this.selectedDestinationAccount,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      isEditMode: isEditMode ?? this.isEditMode,
      editingTransactionId: editingTransactionId ?? this.editingTransactionId,
    );
  }

  @override
  List<Object?> get props => [
    transactionType,
    selectedCategory,
    commitmentTaskType,
    selectedPayee,
    selectedDate,
    selectedTime,
    showNoteField,
    selectedSourceAccount,
    selectedDestinationAccount,
    title,
    amount,
    note,
    isEditMode,
    editingTransactionId,
  ];
}

/// Form error state
class TransactionFormError extends TransactionFormState {
  final String message;

  const TransactionFormError(this.message);

  @override
  List<Object> get props => [message];
}
