import 'package:bloc/bloc.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/data/repositories/budget_plan/i_budget_plan_repository.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_params.dart';
import 'edit_budget_plan_form_event.dart';
import 'edit_budget_plan_form_state.dart';

/// Edit Budget Plan Form BLoC
///
/// Three root causes of the silent save bug — all fixed:
///
///   1. [EditBudgetPlanFormReady] had no [planId] field (see state file).
///      The bloc had no id to pass to [updatePlan], so nothing was written.
///
///   2. [_onInitialize] was an empty stub that emitted a blank Ready state,
///      so [planId] was always ''. Now it fetches the real plan and
///      pre-populates all fields including [planId].
///
///   3. [_onSave] emitted [EditBudgetPlanFormSuccess] immediately without
///      ever calling the repository. Now it awaits [_repository.updatePlan]
///      and only emits success after the DB write confirms.
class EditBudgetPlanFormBloc
    extends Bloc<EditBudgetPlanFormEvent, EditBudgetPlanFormState> {
  final IBudgetPlanRepository _repository;

  EditBudgetPlanFormBloc()
    : _repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository(),
      super(EditBudgetPlanFormLoading()) {
    on<InitializeEditBudgetPlan>(_onInitialize);
    on<EditChangePlanName>(_onChangeName);
    on<EditChangeTargetAmount>(_onChangeTargetAmount);
    on<EditChangeCurrentAmount>(_onChangeCurrentAmount);
    on<EditChangeStartDate>(_onChangeStartDate);
    on<EditChangeEndDate>(_onChangeEndDate);
    on<EditSelectCategory>(_onSelectCategory);
    on<EditChangeAccentColor>(_onChangeAccentColor);
    on<EditChangeStep>(_onChangeStep);
    on<SaveEditBudgetPlan>(_onSave);
  }

  // ---------------------------------------------------------------------------
  // Initialize — fetch existing plan and pre-populate every form field
  // ---------------------------------------------------------------------------

  Future<void> _onInitialize(
    InitializeEditBudgetPlan event,
    Emitter<EditBudgetPlanFormState> emit,
  ) async {
    emit(EditBudgetPlanFormLoading());
    try {
      final plan = await _repository.getPlanByUuid(event.planUuid);

      if (plan == null) {
        emit(
          const EditBudgetPlanFormError(
            'Plan not found. It may have been deleted.',
          ),
        );
        return;
      }

      emit(
        EditBudgetPlanFormReady(
          // planId MUST be populated here — it is the key the save handler
          // passes to updatePlan(). If it stays empty the WHERE clause in
          // the repository matches nothing and no row is updated.
          planId: plan.id,
          name: plan.name,
          description: plan.description ?? '',
          targetAmount: plan.targetAmount,
          currentAmount: plan.currentAmount,
          startDate: plan.startDate,
          endDate: plan.targetDate,
          category: plan.category,
          accentColorValue: _hexToInt(plan.colorHex),
        ),
      );
    } catch (e) {
      emit(EditBudgetPlanFormError('Failed to load plan: ${e.toString()}'));
    }
  }

  // ---------------------------------------------------------------------------
  // Field-change handlers — synchronous, no DB calls
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Save — the actual DB write
  // ---------------------------------------------------------------------------

  Future<void> _onSave(
    SaveEditBudgetPlan event,
    Emitter<EditBudgetPlanFormState> emit,
  ) async {
    if (state is! EditBudgetPlanFormReady) return;
    final current = state as EditBudgetPlanFormReady;

    // Safety net: if planId is somehow still empty, initialization never ran.
    if (current.planId.isEmpty) {
      emit(
        const EditBudgetPlanFormError(
          'Cannot save: plan ID is missing. Close and reopen the edit screen.',
        ),
      );
      return;
    }

    // Validate target date is after start date
    if (current.endDate.isBefore(current.startDate) ||
        current.endDate.isAtSameMomentAs(current.startDate)) {
      emit(
        const EditBudgetPlanFormError(
          'Target date must be after the start date.',
        ),
      );
      return;
    }

    emit(current.copyWith(isLoading: true));

    try {
      await _repository.updatePlan(
        current.planId,
        UpdateBudgetPlanParams(
          name: current.name,
          description: current.description,
          category: current.category,
          targetAmount: current.targetAmount,
          targetDate: current.endDate,
          colorHex: _intToHex(current.accentColorValue),
        ),
      );

      emit(const EditBudgetPlanFormSuccess('Plan updated successfully'));
    } catch (e) {
      // Restore the ready state so the user can retry without re-entering data.
      emit(current.copyWith(isLoading: false));
      emit(EditBudgetPlanFormError('Failed to save: ${e.toString()}'));
    }
  }

  void _onChangeStep(
    EditChangeStep event,
    Emitter<EditBudgetPlanFormState> emit,
  ) {
    if (state is EditBudgetPlanFormReady) {
      emit(
        (state as EditBudgetPlanFormReady).copyWith(currentStep: event.step),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Colour helpers
  // ---------------------------------------------------------------------------

  int _hexToInt(String? hex) {
    if (hex == null || hex.isEmpty) return 0;
    final clean = hex.replaceFirst('#', '');
    if (clean.length == 6) return int.tryParse('FF$clean', radix: 16) ?? 0;
    if (clean.length == 8) return int.tryParse(clean, radix: 16) ?? 0;
    return 0;
  }

  String _intToHex(int value) =>
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
