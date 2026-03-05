import 'package:bloc/bloc.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'transaction_form_event.dart';
import 'transaction_form_state.dart';

/// Transaction Form BLoC - manages add transaction form state
class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  TransactionFormBloc() : super(TransactionFormInitial()) {
    on<InitializeTransactionForm>(_onInitialize);
    on<ChangeTransactionType>(_onChangeType);
    on<SelectCategory>(_onSelectCategory);
    on<ChangeTransactionDate>(_onChangeDate);
    on<ToggleNoteField>(_onToggleNoteField);
    on<SelectSourceAccount>(_onSelectSourceAccount);
    on<SelectDestinationAccount>(_onSelectDestinationAccount);
    on<ClearTransactionForm>(_onClear);
  }

  void _onInitialize(
    InitializeTransactionForm event,
    Emitter<TransactionFormState> emit,
  ) {
    emit(
      TransactionFormReady(
        transactionType: event.preselectedType ?? TransactionType.expense,
      ),
    );
  }

  void _onChangeType(
    ChangeTransactionType event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(
        currentState.copyWith(
          transactionType: event.type,
          selectedCategory: null, // Reset category when type changes
        ),
      );
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(currentState.copyWith(selectedCategory: event.category));
    }
  }

  void _onChangeDate(
    ChangeTransactionDate event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(currentState.copyWith(selectedDate: event.date));
    }
  }

  void _onToggleNoteField(
    ToggleNoteField event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(currentState.copyWith(showNoteField: event.show));
    }
  }

  void _onSelectSourceAccount(
    SelectSourceAccount event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(currentState.copyWith(selectedSourceAccount: event.accountId));
    }
  }

  void _onSelectDestinationAccount(
    SelectDestinationAccount event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is TransactionFormReady) {
      final currentState = state as TransactionFormReady;
      emit(currentState.copyWith(selectedDestinationAccount: event.accountId));
    }
  }

  void _onClear(
    ClearTransactionForm event,
    Emitter<TransactionFormState> emit,
  ) {
    emit(TransactionFormReady());
  }
}
