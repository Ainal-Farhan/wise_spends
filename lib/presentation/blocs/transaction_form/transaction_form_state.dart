import 'package:equatable/equatable.dart';
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
  final bool showNoteField;
  final String? selectedSourceAccount;
  final String? selectedDestinationAccount;

  TransactionFormReady({
    this.transactionType = TransactionType.expense,
    this.selectedCategory,
    DateTime? selectedDate,
    this.showNoteField = false,
    this.selectedSourceAccount,
    this.selectedDestinationAccount,
  }) : selectedDate = selectedDate ?? DateTime.now();

  @override
  List<Object?> get props => [
    transactionType,
    selectedCategory,
    selectedDate,
    showNoteField,
    selectedSourceAccount,
    selectedDestinationAccount,
  ];

  TransactionFormReady copyWith({
    TransactionType? transactionType,
    CategoryEntity? selectedCategory,
    DateTime? selectedDate,
    bool? showNoteField,
    String? selectedSourceAccount,
    String? selectedDestinationAccount,
  }) {
    return TransactionFormReady(
      transactionType: transactionType ?? this.transactionType,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedDate: selectedDate ?? this.selectedDate,
      showNoteField: showNoteField ?? this.showNoteField,
      selectedSourceAccount:
          selectedSourceAccount ?? this.selectedSourceAccount,
      selectedDestinationAccount:
          selectedDestinationAccount ?? this.selectedDestinationAccount,
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
