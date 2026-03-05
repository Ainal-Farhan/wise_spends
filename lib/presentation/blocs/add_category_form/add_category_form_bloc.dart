import 'package:bloc/bloc.dart';
import 'add_category_form_event.dart';
import 'add_category_form_state.dart';

/// Add Category Form BLoC
class AddCategoryFormBloc
    extends Bloc<AddCategoryFormEvent, AddCategoryFormState> {
  AddCategoryFormBloc() : super(const AddCategoryFormReady()) {
    on<InitializeAddCategoryForm>(_onInitialize);
    on<AddCategoryChangeName>(_onChangeName);
    on<AddCategoryChangeType>(_onChangeType);
    on<AddCategorySelectIcon>(_onSelectIcon);
    on<ClearAddCategoryForm>(_onClear);
  }

  void _onInitialize(
    InitializeAddCategoryForm event,
    Emitter<AddCategoryFormState> emit,
  ) {
    emit(const AddCategoryFormReady());
  }

  void _onChangeName(
    AddCategoryChangeName event,
    Emitter<AddCategoryFormState> emit,
  ) {
    if (state is AddCategoryFormReady) {
      emit((state as AddCategoryFormReady).copyWith(name: event.name));
    }
  }

  void _onChangeType(
    AddCategoryChangeType event,
    Emitter<AddCategoryFormState> emit,
  ) {
    if (state is AddCategoryFormReady) {
      emit((state as AddCategoryFormReady).copyWith(type: event.type));
    }
  }

  void _onSelectIcon(
    AddCategorySelectIcon event,
    Emitter<AddCategoryFormState> emit,
  ) {
    if (state is AddCategoryFormReady) {
      emit((state as AddCategoryFormReady).copyWith(
        iconCodePoint: event.iconCodePoint,
      ));
    }
  }

  void _onClear(
    ClearAddCategoryForm event,
    Emitter<AddCategoryFormState> emit,
  ) {
    emit(const AddCategoryFormReady());
  }
}
