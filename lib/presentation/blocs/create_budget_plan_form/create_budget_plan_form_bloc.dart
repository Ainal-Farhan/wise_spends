import 'package:bloc/bloc.dart';
import 'create_budget_plan_form_event.dart';
import 'create_budget_plan_form_state.dart';

/// Create Budget Plan Form BLoC
class CreateBudgetPlanFormBloc
    extends Bloc<CreateBudgetPlanFormEvent, CreateBudgetPlanFormState> {
  CreateBudgetPlanFormBloc() : super(CreateBudgetPlanFormReady()) {
    on<InitializeCreateBudgetPlanForm>(_onInitialize);
    on<ChangePlanName>(_onChangeName);
    on<ChangeTargetAmount>(_onChangeTargetAmount);
    on<ChangeCurrentAmount>(_onChangeCurrentAmount);
    on<ChangeStartDate>(_onChangeStartDate);
    on<ChangeEndDate>(_onChangeEndDate);
    on<SelectBudgetPlanCategory>(_onSelectCategory);
    on<ToggleMilestone>(_onToggleMilestone);
    on<AddMilestone>(_onAddMilestone);
    on<ClearCreateBudgetPlanForm>(_onClear);
    on<ChangeAccentColor>(_onChangeAccentColor);
    on<ChangeCurrentStep>(_onChangeCurrentStep);
  }

  void _onInitialize(
    InitializeCreateBudgetPlanForm event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    emit(CreateBudgetPlanFormReady());
  }

  void _onChangeName(
    ChangePlanName event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit((state as CreateBudgetPlanFormReady).copyWith(name: event.name));
    }
  }

  void _onChangeTargetAmount(
    ChangeTargetAmount event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(
          targetAmount: event.amount,
        ),
      );
    }
  }

  void _onChangeCurrentAmount(
    ChangeCurrentAmount event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(
          currentAmount: event.amount,
        ),
      );
    }
  }

  void _onChangeStartDate(
    ChangeStartDate event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(startDate: event.date),
      );
    }
  }

  void _onChangeEndDate(
    ChangeEndDate event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit((state as CreateBudgetPlanFormReady).copyWith(endDate: event.date));
    }
  }

  void _onSelectCategory(
    SelectBudgetPlanCategory event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(category: event.category),
      );
    }
  }

  void _onToggleMilestone(
    ToggleMilestone event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      final currentState = state as CreateBudgetPlanFormReady;
      final updatedMilestones = List<Map<String, dynamic>>.from(
        currentState.milestones,
      );
      if (event.index < updatedMilestones.length) {
        updatedMilestones[event.index]['isCompleted'] = event.isCompleted;
      }
      emit(currentState.copyWith(milestones: updatedMilestones));
    }
  }

  void _onAddMilestone(
    AddMilestone event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      final currentState = state as CreateBudgetPlanFormReady;
      final updatedMilestones =
          List<Map<String, dynamic>>.from(currentState.milestones)..add({
            'title': event.title,
            'targetAmount': event.targetAmount,
            'isCompleted': false,
          });
      emit(currentState.copyWith(milestones: updatedMilestones));
    }
  }

  void _onClear(
    ClearCreateBudgetPlanForm event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    emit(CreateBudgetPlanFormReady());
  }

  void _onChangeAccentColor(
    ChangeAccentColor event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(
          accentColorValue: event.colorValue,
        ),
      );
    }
  }

  void _onChangeCurrentStep(
    ChangeCurrentStep event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      emit(
        (state as CreateBudgetPlanFormReady).copyWith(currentStep: event.step),
      );
    }
  }
}
