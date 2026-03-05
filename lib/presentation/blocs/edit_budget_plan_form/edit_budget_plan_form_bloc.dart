import 'package:bloc/bloc.dart';
import 'edit_budget_plan_form_event.dart';
import 'edit_budget_plan_form_state.dart';

/// Edit Budget Plan Form BLoC
class EditBudgetPlanFormBloc
    extends Bloc<EditBudgetPlanFormEvent, EditBudgetPlanFormState> {
  EditBudgetPlanFormBloc() : super(EditBudgetPlanFormReady()) {
    on<InitializeEditBudgetPlan>(_onInitialize);
    on<EditChangePlanName>(_onChangeName);
    on<EditChangeTargetAmount>(_onChangeTargetAmount);
    on<EditChangeCurrentAmount>(_onChangeCurrentAmount);
    on<EditChangeStartDate>(_onChangeStartDate);
    on<EditChangeEndDate>(_onChangeEndDate);
    on<EditSelectCategory>(_onSelectCategory);
    on<EditChangeAccentColor>(_onChangeAccentColor);
    on<SaveEditBudgetPlan>(_onSave);
  }

  void _onInitialize(
    InitializeEditBudgetPlan event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    // Load existing plan data here
    emit(EditBudgetPlanFormReady());
  }

  void _onChangeName(
    EditChangePlanName event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit((state as EditBudgetPlanFormReady).copyWith(name: event.name));
    }
  }

  void _onChangeTargetAmount(
    EditChangeTargetAmount event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit(
        (state as EditBudgetPlanFormReady).copyWith(targetAmount: event.amount),
      );
    }
  }

  void _onChangeCurrentAmount(
    EditChangeCurrentAmount event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit(
        (state as EditBudgetPlanFormReady).copyWith(
          currentAmount: event.amount,
        ),
      );
    }
  }

  void _onChangeStartDate(
    EditChangeStartDate event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit((state as EditBudgetPlanFormReady).copyWith(startDate: event.date));
    }
  }

  void _onChangeEndDate(
    EditChangeEndDate event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit((state as EditBudgetPlanFormReady).copyWith(endDate: event.date));
    }
  }

  void _onSelectCategory(
    EditSelectCategory event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit(
        (state as EditBudgetPlanFormReady).copyWith(category: event.category),
      );
    }
  }

  void _onChangeAccentColor(
    EditChangeAccentColor event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit(
        (state as EditBudgetPlanFormReady).copyWith(
          accentColorValue: event.colorValue,
        ),
      );
    }
  }

  void _onSave(
    SaveEditBudgetPlan event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit((state as EditBudgetPlanFormReady).copyWith(isLoading: true));
      // Emit success after save (actual save logic in screen)
      emit(const EditBudgetPlanFormSuccess('Plan updated successfully'));
    }
  }
}
