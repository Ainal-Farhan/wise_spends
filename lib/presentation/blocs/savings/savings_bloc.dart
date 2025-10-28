import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/savings_repository.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final ISavingsRepository _repository;

  SavingsBloc(this._repository) : super(SavingsInitial()) {
    on<LoadSavingsListEvent>(_onLoadSavingsList);
    on<LoadAddSavingsFormEvent>(_onLoadAddSavingsForm);
    on<LoadEditSavingsEvent>(_onLoadEditSavings);
    on<LoadSavingTransactionEvent>(_onLoadSavingTransaction);
    on<AddSavingsEvent>(_onAddSavings);
    on<UpdateSavingsEvent>(_onUpdateSavings);
  }

  Future<void> _onLoadSavingsList(
    LoadSavingsListEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final savingsList = await _repository.getSavingsList();
      emit(SavingsListLoaded(savingsList));
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onLoadAddSavingsForm(
    LoadAddSavingsFormEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final moneyStorageOptions = await _repository.getMoneyStorageOptions();
      emit(
        SavingsFormLoaded(
          isEditing: false,
          moneyStorageOptions: moneyStorageOptions,
        ),
      );
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onLoadEditSavings(
    LoadEditSavingsEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      final saving = await _repository.getSavingById(event.id);
      final moneyStorageOptions = await _repository.getMoneyStorageOptions();

      if (saving != null) {
        emit(
          SavingsFormLoaded(
            isEditing: true,
            saving: saving,
            moneyStorageOptions: moneyStorageOptions,
          ),
        );
      } else {
        emit(SavingsError('Saving not found'));
      }
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onLoadSavingTransaction(
    LoadSavingTransactionEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingTransactionFormLoaded(event.savingId));
  }

  Future<void> _onAddSavings(
    AddSavingsEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      await _repository.addSaving(
        name: event.name,
        initialAmount: event.initialAmount,
        isHasGoal: event.isHasGoal,
        goalAmount: event.goalAmount,
        moneyStorageId: event.moneyStorageId,
        savingType: event.savingType,
      );
      emit(SavingsSuccess('Successfully added saving'));
      // Reload the list after successful addition
      add(LoadSavingsListEvent());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onUpdateSavings(
    UpdateSavingsEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());
    try {
      await _repository.updateSaving(
        id: event.id,
        name: event.name,
        initialAmount: event.initialAmount,
        isHasGoal: event.isHasGoal,
        goalAmount: event.goalAmount,
        moneyStorageId: event.moneyStorageId,
        savingType: event.savingType,
      );
      emit(SavingsSuccess('Successfully updated saving'));
      // Reload the list after successful update
      add(LoadSavingsListEvent());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }
}
