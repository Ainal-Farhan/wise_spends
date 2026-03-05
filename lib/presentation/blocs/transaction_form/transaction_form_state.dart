import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wise_spends/domain/entities/category/category_entity.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';

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
  final DateTime selectedDate;
  final TimeOfDay? selectedTime;
  final bool showNoteField;
  final String? selectedSourceAccount;
  final String? selectedDestinationAccount;
  final String? title;
  final String? amount;
  final String? note;
  final bool isEditMode;
  final String? editingTransactionId;

  TransactionFormReady({
    this.transactionType = TransactionType.expense,
    this.selectedCategory,
    DateTime? selectedDate,
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

  @override
  List<Object?> get props => [
    transactionType,
    selectedCategory,
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

  TransactionFormReady copyWith({
    TransactionType? transactionType,
    CategoryEntity? selectedCategory,
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
  }) {
    return TransactionFormReady(
      transactionType: transactionType ?? this.transactionType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
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
}

/// Form error state
class TransactionFormError extends TransactionFormState {
  final String message;

  const TransactionFormError(this.message);

  @override
  List<Object> get props => [message];
}
