import 'package:bloc/bloc.dart';
import 'package:wise_spends/data/repositories/saving/i_money_storage_repository.dart';
import 'money_storage_event.dart';
import 'money_storage_state.dart';

class MoneyStorageBloc extends Bloc<MoneyStorageEvent, MoneyStorageState> {
  final IMoneyStorageRepository _repository;

  MoneyStorageBloc(this._repository) : super(MoneyStorageInitial()) {
    on<LoadMoneyStorageListEvent>(_onLoadMoneyStorageList);
    on<LoadAddMoneyStorageEvent>(_onLoadAddMoneyStorage);
    on<LoadEditMoneyStorageEvent>(_onLoadEditMoneyStorage);
    on<AddMoneyStorageEvent>(_onAddMoneyStorage);
    on<UpdateMoneyStorageEvent>(_onUpdateMoneyStorage);
    on<DeleteMoneyStorageEvent>(_onDeleteMoneyStorage);
  }

  Future<void> _onLoadMoneyStorageList(
    LoadMoneyStorageListEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageLoading());
    try {
      final moneyStorageList = await _repository.getMoneyStorageList();
      emit(MoneyStorageListLoaded(moneyStorageList));
    } catch (e) {
      emit(MoneyStorageError(e.toString()));
    }
  }

  Future<void> _onLoadAddMoneyStorage(
    LoadAddMoneyStorageEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageFormLoaded(isEditing: false));
  }

  Future<void> _onLoadEditMoneyStorage(
    LoadEditMoneyStorageEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageLoading());
    try {
      final moneyStorage = await _repository.getMoneyStorageById(event.id);
      if (moneyStorage != null) {
        emit(
          MoneyStorageFormLoaded(isEditing: true, moneyStorage: moneyStorage),
        );
      } else {
        emit(MoneyStorageError('Money storage not found'));
      }
    } catch (e) {
      emit(MoneyStorageError(e.toString()));
    }
  }

  Future<void> _onAddMoneyStorage(
    AddMoneyStorageEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageLoading());
    try {
      await _repository.addMoneyStorage(
        event.shortName,
        event.longName,
        event.amount,
      );
      emit(MoneyStorageSuccess('Successfully added money storage'));
      // Reload the list after successful addition
      add(LoadMoneyStorageListEvent());
    } catch (e) {
      emit(MoneyStorageError(e.toString()));
    }
  }

  Future<void> _onUpdateMoneyStorage(
    UpdateMoneyStorageEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageLoading());
    try {
      await _repository.updateMoneyStorage(
        event.id,
        event.shortName,
        event.longName,
        event.amount,
      );
      emit(MoneyStorageSuccess('Successfully updated money storage'));
      // Reload the list after successful update
      add(LoadMoneyStorageListEvent());
    } catch (e) {
      emit(MoneyStorageError(e.toString()));
    }
  }

  Future<void> _onDeleteMoneyStorage(
    DeleteMoneyStorageEvent event,
    Emitter<MoneyStorageState> emit,
  ) async {
    emit(MoneyStorageLoading());
    try {
      await _repository.deleteMoneyStorage(event.id);
      emit(MoneyStorageSuccess('Successfully deleted money storage'));
      // Reload the list after successful deletion
      add(LoadMoneyStorageListEvent());
    } catch (e) {
      emit(MoneyStorageError(e.toString()));
    }
  }
}
