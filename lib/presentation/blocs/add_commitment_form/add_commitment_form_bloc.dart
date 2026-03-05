import 'package:bloc/bloc.dart';
import 'add_commitment_form_event.dart';
import 'add_commitment_form_state.dart';

/// Add Commitment Form BLoC
class AddCommitmentFormBloc
    extends Bloc<AddCommitmentFormEvent, AddCommitmentFormState> {
  AddCommitmentFormBloc() : super(const AddCommitmentFormReady()) {
    on<InitializeAddCommitmentForm>(_onInitialize);
    on<AddCommitmentChangeName>(_onChangeName);
    on<AddCommitmentChangeFrequency>(_onChangeFrequency);
    on<ClearAddCommitmentForm>(_onClear);
    on<AddCommitmentSelectSaving>(_onSelectSaving);
  }

  void _onInitialize(
    InitializeAddCommitmentForm event,
    Emitter<AddCommitmentFormState> emit,
  ) {
    emit(const AddCommitmentFormReady());
  }

  void _onChangeName(
    AddCommitmentChangeName event,
    Emitter<AddCommitmentFormState> emit,
  ) {
    if (state is AddCommitmentFormReady) {
      emit((state as AddCommitmentFormReady).copyWith(name: event.name));
    }
  }

  void _onChangeFrequency(
    AddCommitmentChangeFrequency event,
    Emitter<AddCommitmentFormState> emit,
  ) {
    if (state is AddCommitmentFormReady) {
      emit((state as AddCommitmentFormReady).copyWith(frequency: event.frequency));
    }
  }

  void _onClear(
    ClearAddCommitmentForm event,
    Emitter<AddCommitmentFormState> emit,
  ) {
    emit(const AddCommitmentFormReady());
  }

  void _onSelectSaving(
    AddCommitmentSelectSaving event,
    Emitter<AddCommitmentFormState> emit,
  ) {
    if (state is AddCommitmentFormReady) {
      emit((state as AddCommitmentFormReady).copyWith(selectedSavingId: event.savingId));
    }
  }
}
