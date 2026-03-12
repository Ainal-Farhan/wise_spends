import 'package:bloc/bloc.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'transaction_form_event.dart';
import 'transaction_form_state.dart';

class TransactionFormBloc
    extends Bloc<TransactionFormEvent, TransactionFormState> {
  TransactionFormBloc() : super(TransactionFormInitial()) {
    on<InitializeTransactionForm>(_onInitialize);
    on<InitializeTransactionFormForEdit>(_onInitializeForEdit);
    on<ChangeTransactionType>(_onChangeType);
    on<SelectCategory>(_onSelectCategory);
    on<SelectPayee>(_onSelectPayee);
    on<ChangeTransactionDate>(_onChangeDate);
    on<ChangeTransactionTime>(_onChangeTime);
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

  void _onInitializeForEdit(
    InitializeTransactionFormForEdit event,
    Emitter<TransactionFormState> emit,
  ) {
    emit(
      TransactionFormReady(
        transactionType: event.transaction.type,
        selectedCategory: event.category,
        selectedPayee: event.payee,
        commitmentTaskType: event.commitmentTaskVO?.type,
        selectedDate: event.transaction.date,
        selectedTime: event.selectedTime,
        showNoteField:
            event.transaction.note != null &&
            event.transaction.note!.isNotEmpty,
        selectedSourceAccount: event.transaction.sourceAccountId,
        selectedDestinationAccount: event.transaction.destinationSavingId,
        title: event.transaction.title,
        amount: event.transaction.amount.toString(),
        note: event.transaction.note,
        isEditMode: true,
        editingTransactionId: event.transaction.id,
      ),
    );
  }

  void _onChangeType(
    ChangeTransactionType event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(
      current.copyWith(
        transactionType: event.type,
        clearCategory: true,
        // Clear payee if switching to a type that doesn't support it
        clearPayee:
            event.type != TransactionType.expense &&
            event.type != TransactionType.commitment,
      ),
    );
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(selectedCategory: event.category));
  }

  void _onSelectPayee(SelectPayee event, Emitter<TransactionFormState> emit) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    if (event.payee == null) {
      emit(current.copyWith(clearPayee: true));
    } else {
      emit(current.copyWith(selectedPayee: event.payee));
    }
  }

  void _onChangeDate(
    ChangeTransactionDate event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(selectedDate: event.date));
  }

  void _onChangeTime(
    ChangeTransactionTime event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(selectedTime: event.time));
  }

  void _onToggleNoteField(
    ToggleNoteField event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(showNoteField: event.show));
  }

  void _onSelectSourceAccount(
    SelectSourceAccount event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(selectedSourceAccount: event.accountId));
  }

  void _onSelectDestinationAccount(
    SelectDestinationAccount event,
    Emitter<TransactionFormState> emit,
  ) {
    if (state is! TransactionFormReady) return;
    final current = state as TransactionFormReady;
    emit(current.copyWith(selectedDestinationAccount: event.accountId));
  }

  void _onClear(
    ClearTransactionForm event,
    Emitter<TransactionFormState> emit,
  ) {
    emit(TransactionFormReady());
  }
}
