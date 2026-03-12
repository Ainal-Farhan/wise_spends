import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/data/repositories/i_budget_plan_repository.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_params.dart';
import 'create_budget_plan_form_event.dart';
import 'create_budget_plan_form_state.dart';

/// Create Budget Plan Form BLoC
///
/// Root cause of the silent create bug:
///   • The bloc had no repository — it was a pure form-state manager.
///   • No [SaveCreateBudgetPlan] event / handler existed.
///   • The screen's [_submit] just popped and reloaded the list without ever
///     calling [createPlan], so the DB was never written to.
///
/// Fixes:
///   • Repository injected via service locator (zero-arg constructor kept
///     so no call sites need changing).
///   • [SaveCreateBudgetPlan] event added and handled in [_onSave].
///   • [_onSave] awaits [_repository.createPlan], emits
///     [CreateBudgetPlanFormSuccess] on success or restores [isLoading: false]
///     and emits [CreateBudgetPlanFormError] on failure.
///   • The screen's [_submit] is reduced to dispatching
///     [SaveCreateBudgetPlan()]; all result handling moves to the
///     [BlocListener].
class CreateBudgetPlanFormBloc
    extends Bloc<CreateBudgetPlanFormEvent, CreateBudgetPlanFormState> {
  final IBudgetPlanRepository _repository;

  CreateBudgetPlanFormBloc()
    : _repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository(),
      super(CreateBudgetPlanFormReady()) {
    on<InitializeCreateBudgetPlanForm>(_onInitialize);
    on<ChangePlanName>(_onChangeName);
    on<ChangeTargetAmount>(_onChangeTargetAmount);
    on<ChangeCurrentAmount>(_onChangeCurrentAmount);
    on<ChangeStartDate>(_onChangeStartDate);
    on<ChangeEndDate>(_onChangeEndDate);
    on<SelectBudgetPlanCategory>(_onSelectCategory);
    on<ToggleMilestone>(_onToggleMilestone);
    on<AddMilestone>(_onAddMilestone);
    on<RemoveMilestone>(_onRemoveMilestone);
    on<ClearCreateBudgetPlanForm>(_onClear);
    on<ChangeAccentColor>(_onChangeAccentColor);
    on<ChangeCurrentStep>(_onChangeCurrentStep);
    on<SaveCreateBudgetPlan>(_onSave);
  }

  // ---------------------------------------------------------------------------
  // Initialize
  // ---------------------------------------------------------------------------

  void _onInitialize(
    InitializeCreateBudgetPlanForm event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    emit(CreateBudgetPlanFormReady());
  }

  // ---------------------------------------------------------------------------
  // Field-change handlers
  // ---------------------------------------------------------------------------

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
      final current = state as CreateBudgetPlanFormReady;
      final updated = List<Map<String, dynamic>>.from(current.milestones);
      if (event.index < updated.length) {
        updated[event.index] = {
          ...updated[event.index],
          'isCompleted': event.isCompleted,
        };
      }
      emit(current.copyWith(milestones: updated));
    }
  }

  void _onAddMilestone(
    AddMilestone event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      final current = state as CreateBudgetPlanFormReady;
      final updated = List<Map<String, dynamic>>.from(current.milestones)
        ..add({
          'title': event.title,
          'targetAmount': event.targetAmount,
          'isCompleted': false,
        });
      emit(current.copyWith(milestones: updated));
    }
  }

  void _onRemoveMilestone(
    RemoveMilestone event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) {
    if (state is CreateBudgetPlanFormReady) {
      final current = state as CreateBudgetPlanFormReady;
      final updated = List<Map<String, dynamic>>.from(current.milestones);
      if (event.index >= 0 && event.index < updated.length) {
        updated.removeAt(event.index);
      }
      emit(current.copyWith(milestones: updated));
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

  // ---------------------------------------------------------------------------
  // Save — the actual DB write
  // ---------------------------------------------------------------------------

  Future<void> _onSave(
    SaveCreateBudgetPlan event,
    Emitter<CreateBudgetPlanFormState> emit,
  ) async {
    if (state is! CreateBudgetPlanFormReady) return;
    final current = state as CreateBudgetPlanFormReady;

    emit(current.copyWith(isLoading: true));

    try {
      // Build milestone params from the form list, if any were added.
      final milestoneParams = current.milestones
          .map(
            (m) => CreateMilestoneParams(
              title: m['title'] as String,
              targetAmount: (m['targetAmount'] as num).toDouble(),
              dueDate: m['dueDate'] as DateTime?,
            ),
          )
          .toList();

      await _repository.createPlan(
        CreateBudgetPlanParams(
          name: current.name,
          description: current.description,
          category: current.category,
          targetAmount: current.targetAmount,
          startDate: current.startDate,
          targetDate: current.endDate,
          colorHex: _intToHex(current.accentColorValue),
          milestones: milestoneParams.isEmpty ? null : milestoneParams,
        ),
      );

      emit(const CreateBudgetPlanFormSuccess('Plan created successfully'));
    } catch (e) {
      // Restore ready state so the user can retry without re-entering data.
      emit(current.copyWith(isLoading: false));
      emit(CreateBudgetPlanFormError('Failed to create plan: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _intToHex(int value) =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
