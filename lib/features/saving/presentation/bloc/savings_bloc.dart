import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/constants/constant/domain/saving_table_type_enum.dart';
import 'package:wise_spends/features/saving/data/repositories/i_saving_repository.dart';
import 'package:wise_spends/features/saving/domain/entities/list_saving_vo.dart';
import 'savings_event.dart';
import 'savings_state.dart';

class SavingsBloc extends Bloc<SavingsEvent, SavingsState> {
  final ISavingRepository _repository;

  SavingsBloc(this._repository) : super(SavingsInitial()) {
    on<LoadSavingsListEvent>(_onLoadSavingsList);
    on<LoadAddSavingsFormEvent>(_onLoadAddSavingsForm);
    on<LoadEditSavingsEvent>(_onLoadEditSavings);
    on<LoadSavingTransactionEvent>(_onLoadSavingTransaction);
    on<AddSavingsEvent>(_onAddSavings);
    on<UpdateSavingsEvent>(_onUpdateSavings);
    on<DeleteSavingEvent>(_onDeleteSaving);
    on<ReorderSavingsEvent>(_onReorderSavings);
  }

  Future<void> _onDeleteSaving(
    DeleteSavingEvent event,
    Emitter<SavingsState> emit,
  ) async {
    emit(SavingsLoading());

    try {
      // Store for undo
      final allSavings = await _repository.getSavingsList();
      final deletedSaving = allSavings.firstWhere(
        (s) => s.saving.id == event.id,
        orElse: () => throw Exception('Saving not found'),
      );

      await _repository.deleteSaving(event.id);

      // Store for potential undo
      _deletedSavingBuffer[event.id] = deletedSaving;
      Future.delayed(const Duration(seconds: 5), () {
        _deletedSavingBuffer.remove(event.id);
      });

      emit(SavingsSuccess('Saving deleted'));
      add(LoadSavingsListEvent());
    } catch (e) {
      emit(SavingsError('Failed to delete: ${e.toString()}'));
    }
  }

  /// Undo delete
  Future<void> undoDelete(String id) async {
    final saving = _deletedSavingBuffer.remove(id);
    if (saving != null) {
      // Would need to re-insert - for now just reload
      add(LoadSavingsListEvent());
    }
  }

  final Map<String, dynamic> _deletedSavingBuffer = {};

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
      final savingTypeOptions = await _loadSavingTypeOptions();
      emit(
        SavingsFormLoaded(
          isEditing: false,
          moneyStorageOptions: moneyStorageOptions,
          savingTypeOptions: savingTypeOptions,
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
      final savingTypeOptions = await _loadSavingTypeOptions();

      if (saving != null) {
        emit(
          SavingsFormLoaded(
            isEditing: true,
            saving: saving,
            moneyStorageOptions: moneyStorageOptions,
            savingTypeOptions: savingTypeOptions,
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
      if (event.moneyStorageId.trim().isEmpty) {
        emit(SavingsError('Please select a money storage'));
        return;
      }

      await _repository.addSaving(
        name: event.name,
        initialAmount: event.initialAmount,
        isHasGoal: event.isHasGoal,
        goalAmount: event.goalAmount,
        moneyStorageId: event.moneyStorageId,
        savingType: event.savingType,
        categoryId: event.categoryId,
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
      if (event.moneyStorageId.trim().isEmpty) {
        emit(SavingsError('Please select a money storage'));
        return;
      }

      await _repository.updateSaving(
        id: event.id,
        name: event.name,
        initialAmount: event.initialAmount,
        isHasGoal: event.isHasGoal,
        goalAmount: event.goalAmount,
        moneyStorageId: event.moneyStorageId,
        savingType: event.savingType,
        categoryId: event.categoryId,
      );
      emit(SavingsSuccess('Successfully updated saving'));
      // Reload the list after successful update
      add(LoadSavingsListEvent());
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<void> _onReorderSavings(
    ReorderSavingsEvent event,
    Emitter<SavingsState> emit,
  ) async {
    try {
      final currentState = state;
      if (currentState is SavingsListLoaded) {
        final savingMap = {
          for (final saving in currentState.savingsList)
            saving.saving.id: saving,
        };
        final reorderedSavings = event.orderedSavingIds
            .map((id) => savingMap[id])
            .whereType<ListSavingVO>()
            .toList();
        emit(SavingsListLoaded(reorderedSavings));
      }

      await _repository.reorderSavings(event.orderedSavingIds);
    } catch (e) {
      emit(SavingsError(e.toString()));
    }
  }

  Future<List<String>> _loadSavingTypeOptions() async {
    final options = <String>{
      for (final type in SavingTableType.values) type.label,
    };

    try {
      final savings = await _repository.getSavingsList();
      for (final saving in savings) {
        final label = SavingTableType.displayLabel(saving.saving.type).trim();
        if (label.isNotEmpty) options.add(label);
      }
    } catch (_) {
      // Form can still open with built-in options if savings fail to load.
    }

    final sortedOptions = options.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sortedOptions;
  }
}
