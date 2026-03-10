// ─────────────────────────────────────────────────────────────────────────────
// create_budget_plan_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//
// Refactored highlights
// ─────────────────────────────────────────────────────────────────────────────
// 1. Shared step widgets
//    • _StepBasics, _StepFinancial, _StepMilestones, _StepReview
//      are now standalone StatelessWidgets that accept a generic
//      BudgetPlanFormData value object and a callback interface
//      (BudgetPlanFormCallbacks).  Both Create and Edit screens
//      just pass in their own data/callbacks — no duplication.
//
// 2. Enhanced mobile wizard bar
//    • Compact numbered dots on narrow screens (< 380 px); full
//      label strip on wider screens.
//    • Animated progress line between steps.
//    • Current step circle uses the plan's accent colour.
//
// 3. Review step in the Create flow (step 3 is now Review;
//    the old step 3 Milestones becomes step 2.5 / inserted before review)
//    Flow: Basics → Financial → Milestones → Review → Save
//
// 4. No logic changes to blocs/events/states — only the UI layer is
//    touched.
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_event.dart';
import 'package:wise_spends/presentation/blocs/create_budget_plan_form/create_budget_plan_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/create_budget_plan_form/create_budget_plan_form_event.dart';
import 'package:wise_spends/presentation/blocs/create_budget_plan_form/create_budget_plan_form_state.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_event.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Accent colour palette
// ─────────────────────────────────────────────────────────────────────────────

class _AccentColors {
  static final List<int> argbValues = [
    AppColors.primary.toARGB32(),
    AppColors.secondary.toARGB32(),
    AppColors.tertiary.toARGB32(),
    AppColors.warning.toARGB32(),
    AppColors.info.toARGB32(),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared data container (read-only snapshot passed to shared step widgets)
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the common form fields used by every step widget.
/// Both [CreateBudgetPlanFormReady] and [EditBudgetPlanFormReady] are
/// projected into this so the step widgets remain bloc-agnostic.
class BudgetPlanFormData {
  final String name;
  final String description;
  final BudgetPlanCategory category;
  final double targetAmount;
  final DateTime startDate;
  final DateTime endDate;
  final int accentColorValue;
  final List<Map<String, dynamic>> milestones;
  final int currentStep;
  final bool isLoading;

  const BudgetPlanFormData({
    required this.name,
    required this.description,
    required this.category,
    required this.targetAmount,
    required this.startDate,
    required this.endDate,
    required this.accentColorValue,
    required this.milestones,
    required this.currentStep,
    required this.isLoading,
  });

  factory BudgetPlanFormData.fromCreate(CreateBudgetPlanFormReady s) =>
      BudgetPlanFormData(
        name: s.name,
        description: s.description,
        category: s.category,
        targetAmount: s.targetAmount,
        startDate: s.startDate,
        endDate: s.endDate,
        accentColorValue: s.accentColorValue,
        milestones: s.milestones,
        currentStep: s.currentStep,
        isLoading: s.isLoading,
      );

  factory BudgetPlanFormData.fromEdit(EditBudgetPlanFormReady s) =>
      BudgetPlanFormData(
        name: s.name,
        description: s.description,
        category: s.category,
        targetAmount: s.targetAmount,
        startDate: s.startDate,
        endDate: s.endDate,
        accentColorValue: AppColors.primary.toARGB32(),
        milestones: const [],
        currentStep: s.currentStep,
        isLoading: s.isLoading,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Callback interface (thin wrapper; each screen supplies its own)
// ─────────────────────────────────────────────────────────────────────────────

class BudgetPlanFormCallbacks {
  final ValueChanged<String> onNameChanged;
  final ValueChanged<BudgetPlanCategory> onCategoryChanged;
  final ValueChanged<int> onAccentColorChanged;
  final ValueChanged<double> onTargetAmountChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final void Function(String title, double amount)? onAddMilestone;
  final ValueChanged<int>? onRemoveMilestone;

  const BudgetPlanFormCallbacks({
    required this.onNameChanged,
    required this.onCategoryChanged,
    required this.onAccentColorChanged,
    required this.onTargetAmountChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.onAddMilestone,
    this.onRemoveMilestone,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// 4-step wizard: Basics → Financial → Milestones → Review
class CreateBudgetPlanScreen extends StatelessWidget {
  const CreateBudgetPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CreateBudgetPlanFormBloc()
            ..add(const InitializeCreateBudgetPlanForm()),
      child: const _CreateBudgetPlanContent(),
    );
  }
}

class _CreateBudgetPlanContent extends StatefulWidget {
  const _CreateBudgetPlanContent();

  @override
  State<_CreateBudgetPlanContent> createState() =>
      _CreateBudgetPlanContentState();
}

class _CreateBudgetPlanContentState extends State<_CreateBudgetPlanContent> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

  // Total steps including the new Review step (0-based index, 4 steps total).
  static const int _totalSteps = 4;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('budget_plans.create'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CreateBudgetPlanFormBloc, CreateBudgetPlanFormState>(
        listener: (context, state) {
          if (state is CreateBudgetPlanFormReady &&
              _nameCtrl.text != state.name) {
            _nameCtrl.text = state.name;
          }
          if (state is CreateBudgetPlanFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('budget_plans.created'.tr),
                backgroundColor: AppColors.success,
              ),
            );
            Navigator.pop(context);
          } else if (state is CreateBudgetPlanFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is! CreateBudgetPlanFormReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = BudgetPlanFormData.fromCreate(state);
          final callbacks = _buildCallbacks(context);

          return Column(
            children: [
              WizardStepBar(
                currentStep: state.currentStep,
                totalSteps: _totalSteps,
                accentColor: Color(state.accentColorValue),
                stepLabels: _stepLabels,
              ),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(state.currentStep),
                    child: _buildStep(
                      step: state.currentStep,
                      data: data,
                      callbacks: callbacks,
                    ),
                  ),
                ),
              ),
              WizardNavBar(
                currentStep: state.currentStep,
                totalSteps: _totalSteps,
                isLoading: state.isLoading,
                accentColor: Color(state.accentColorValue),
                onBack: () => context.read<CreateBudgetPlanFormBloc>().add(
                  ChangeCurrentStep(state.currentStep - 1),
                ),
                onNext: () => _handleNext(context, state),
                finalLabel: 'budget_plans.create'.tr,
              ),
            ],
          );
        },
      ),
    );
  }

  static const List<String> _stepLabels = [
    'budget_plans.step_basics',
    'budget_plans.step_financial',
    'budget_plans.step_milestones',
    'budget_plans.step_review',
  ];

  Widget _buildStep({
    required int step,
    required BudgetPlanFormData data,
    required BudgetPlanFormCallbacks callbacks,
  }) {
    switch (step) {
      case 0:
        return StepBasics(
          data: data,
          callbacks: callbacks,
          nameCtrl: _nameCtrl,
          descCtrl: _descCtrl,
          showAccentColor: true,
        );
      case 1:
        return StepFinancial(
          data: data,
          callbacks: callbacks,
          targetCtrl: _targetCtrl,
        );
      case 2:
        return StepMilestones(data: data, callbacks: callbacks);
      case 3:
        return StepReview(data: data, showMilestones: true);
      default:
        return const SizedBox.shrink();
    }
  }

  BudgetPlanFormCallbacks _buildCallbacks(BuildContext context) {
    final bloc = context.read<CreateBudgetPlanFormBloc>();
    return BudgetPlanFormCallbacks(
      onNameChanged: (v) => bloc.add(ChangePlanName(v)),
      onCategoryChanged: (c) => bloc.add(SelectBudgetPlanCategory(c)),
      onAccentColorChanged: (v) => bloc.add(ChangeAccentColor(v)),
      onTargetAmountChanged: (v) => bloc.add(ChangeTargetAmount(v)),
      onStartDateChanged: (d) => bloc.add(ChangeStartDate(d)),
      onEndDateChanged: (d) => bloc.add(ChangeEndDate(d)),
      onAddMilestone: (t, a) => bloc.add(AddMilestone(t, a)),
      onRemoveMilestone: (i) => bloc.add(RemoveMilestone(i)),
    );
  }

  void _handleNext(BuildContext context, CreateBudgetPlanFormReady state) {
    if (state.currentStep < _totalSteps - 1) {
      // Validate before advancing to Review
      if (state.currentStep == _totalSteps - 2) {
        final err = _validate(state);
        if (err != null) {
          _showError(context, err);
          return;
        }
      }
      context.read<CreateBudgetPlanFormBloc>().add(
        ChangeCurrentStep(state.currentStep + 1),
      );
    } else {
      // Final step — save
      final err = _validate(state);
      if (err != null) {
        _showError(context, err);
        return;
      }
      context.read<CreateBudgetPlanFormBloc>().add(
        const SaveCreateBudgetPlan(),
      );
    }
  }

  String? _validate(CreateBudgetPlanFormReady state) {
    if (state.name.trim().isEmpty) return 'budget_plans.enter_plan_name'.tr;
    if (state.targetAmount <= 0) return 'budget_plans.enter_target'.tr;
    if (!state.endDate.isAfter(state.startDate)) {
      return 'budget_plans.end_date_after_start'.tr;
    }
    return null;
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

/// 3-step wizard: Basics → Financial → Review
class EditBudgetPlanScreen extends StatelessWidget {
  final String planUuid;

  const EditBudgetPlanScreen({super.key, required this.planUuid});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          EditBudgetPlanFormBloc()..add(InitializeEditBudgetPlan(planUuid)),
      child: _EditBudgetPlanContent(planUuid: planUuid),
    );
  }
}

class _EditBudgetPlanContent extends StatefulWidget {
  final String planUuid;
  const _EditBudgetPlanContent({required this.planUuid});

  @override
  State<_EditBudgetPlanContent> createState() => _EditBudgetPlanContentState();
}

class _EditBudgetPlanContentState extends State<_EditBudgetPlanContent> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();
  bool _controllersSynced = false;

  static const int _totalSteps = 3;

  static const List<String> _stepLabels = [
    'budget_plans.step_basics',
    'budget_plans.step_financial',
    'budget_plans.step_review',
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('budget_plans.edit'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<EditBudgetPlanFormBloc, EditBudgetPlanFormState>(
        listener: (context, state) {
          if (state is EditBudgetPlanFormReady && !_controllersSynced) {
            _controllersSynced = true;
            if (_nameCtrl.text != state.name) _nameCtrl.text = state.name;
            if (_descCtrl.text != state.description) {
              _descCtrl.text = state.description;
            }
            final t = state.targetAmount > 0
                ? state.targetAmount.toStringAsFixed(2)
                : '';
            if (_targetCtrl.text != t) _targetCtrl.text = t;
          }
          if (state is EditBudgetPlanFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success,
              ),
            );
            context.read<BudgetPlanListBloc>().add(LoadBudgetPlans());
            Navigator.pop(context);
          } else if (state is EditBudgetPlanFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EditBudgetPlanFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EditBudgetPlanFormReady) {
            final data = BudgetPlanFormData.fromEdit(state);
            final callbacks = _buildCallbacks(context);

            return Column(
              children: [
                WizardStepBar(
                  currentStep: state.currentStep,
                  totalSteps: _totalSteps,
                  accentColor: AppColors.primary,
                  stepLabels: _stepLabels,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(state.currentStep),
                      child: _buildStep(
                        step: state.currentStep,
                        data: data,
                        callbacks: callbacks,
                      ),
                    ),
                  ),
                ),
                WizardNavBar(
                  currentStep: state.currentStep,
                  totalSteps: _totalSteps,
                  isLoading: state.isLoading,
                  accentColor: AppColors.primary,
                  onBack: () => context.read<EditBudgetPlanFormBloc>().add(
                    EditChangeStep(state.currentStep - 1),
                  ),
                  onNext: () => state.currentStep < _totalSteps - 1
                      ? context.read<EditBudgetPlanFormBloc>().add(
                          EditChangeStep(state.currentStep + 1),
                        )
                      : context.read<EditBudgetPlanFormBloc>().add(
                          SaveEditBudgetPlan(),
                        ),
                  finalLabel: 'budget_plans.save_changes'.tr,
                ),
              ],
            );
          }
          if (state is EditBudgetPlanFormError) {
            return _ErrorView(
              message: state.message,
              onRetry: () => context.read<EditBudgetPlanFormBloc>().add(
                InitializeEditBudgetPlan(widget.planUuid),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildStep({
    required int step,
    required BudgetPlanFormData data,
    required BudgetPlanFormCallbacks callbacks,
  }) {
    switch (step) {
      case 0:
        return StepBasics(
          data: data,
          callbacks: callbacks,
          nameCtrl: _nameCtrl,
          descCtrl: _descCtrl,
          showAccentColor: false,
        );
      case 1:
        return StepFinancial(
          data: data,
          callbacks: callbacks,
          targetCtrl: _targetCtrl,
          showStartDate: false,
        );
      case 2:
        return StepReview(data: data, showMilestones: false);
      default:
        return const SizedBox.shrink();
    }
  }

  BudgetPlanFormCallbacks _buildCallbacks(BuildContext context) {
    final bloc = context.read<EditBudgetPlanFormBloc>();
    return BudgetPlanFormCallbacks(
      onNameChanged: (_) {}, // edit: name updated on save via controller
      onCategoryChanged: (c) => bloc.add(EditSelectCategory(c)),
      onAccentColorChanged: (_) {},
      onTargetAmountChanged: (v) => bloc.add(EditChangeTargetAmount(v)),
      onStartDateChanged: (_) {},
      onEndDateChanged: (d) => bloc.add(EditChangeEndDate(d)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED STEP WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

// ── Step 1: Basics ────────────────────────────────────────────────────────────

class StepBasics extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;
  final bool showAccentColor;

  const StepBasics({
    super.key,
    required this.data,
    required this.callbacks,
    required this.nameCtrl,
    required this.descCtrl,
    this.showAccentColor = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.step_basics'.tr,
            subtitle: 'budget_plans.step_basics_subtitle'.tr,
          ),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(
            label: 'budget_plans.plan_name'.tr,
            hint: 'budget_plans.plan_name_hint'.tr,
            controller: nameCtrl,
            onChanged: callbacks.onNameChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'budget_plans.description'.tr,
            hint: 'budget_plans.description_hint'.tr,
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xxl),
          SectionHeaderCompact(title: 'budget_plans.category'.tr),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: BudgetPlanCategory.values.map((cat) {
              final isSelected = data.category == cat;
              return FilterChip(
                label: Text(cat.displayName),
                selected: isSelected,
                avatar: Text(cat.iconCode),
                onSelected: (_) => callbacks.onCategoryChanged(cat),
                selectedColor: Color(
                  data.accentColorValue,
                ).withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          if (showAccentColor) ...[
            const SizedBox(height: AppSpacing.xxl),
            SectionHeaderCompact(title: 'budget_plans.accent_color'.tr),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _AccentColors.argbValues.map((colorValue) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _ColorSwatch(
                    color: Color(colorValue),
                    isSelected: data.accentColorValue == colorValue,
                    onTap: () => callbacks.onAccentColorChanged(colorValue),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Step 2: Financial ─────────────────────────────────────────────────────────

class StepFinancial extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;
  final TextEditingController targetCtrl;
  final bool showStartDate;

  const StepFinancial({
    super.key,
    required this.data,
    required this.callbacks,
    required this.targetCtrl,
    this.showStartDate = true,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.step_financial'.tr,
            subtitle: 'budget_plans.step_financial_subtitle'.tr,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'budget_plans.target_amount'.tr,
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: AppSpacing.sm),
          _AmountField(
            controller: targetCtrl,
            onChanged: (v) =>
                callbacks.onTargetAmountChanged(double.tryParse(v) ?? 0.0),
          ),
          const SizedBox(height: AppSpacing.xxl),
          if (showStartDate) ...[
            _DateField(
              labelKey: 'budget_plans.start_date_label',
              date: data.startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onChanged: callbacks.onStartDateChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          _DateField(
            labelKey: 'budget_plans.target_date_label',
            date: data.endDate,
            firstDate: data.startDate,
            lastDate: DateTime(2100),
            onChanged: callbacks.onEndDateChanged,
          ),
        ],
      ),
    );
  }
}

// ── Step 3: Milestones ────────────────────────────────────────────────────────

class StepMilestones extends StatelessWidget {
  final BudgetPlanFormData data;
  final BudgetPlanFormCallbacks callbacks;

  const StepMilestones({
    super.key,
    required this.data,
    required this.callbacks,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.step_milestones'.tr,
            subtitle: 'budget_plans.milestones_optional'.tr,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.milestones.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                child: Column(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 48,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'budget_plans.no_milestones_yet'.tr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...data.milestones.asMap().entries.map(
              (e) => _MilestoneTile(
                key: ValueKey('milestone-${e.key}'),
                index: e.key,
                milestone: e.value,
                onDelete: () => callbacks.onRemoveMilestone?.call(e.key),
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          AppButton.secondary(
            label: 'budget_plans.add_milestone'.tr,
            icon: Icons.add,
            onPressed: () => _showAddMilestoneDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    showCustomContentDialog(
      context: context,
      title: 'budget_plans.add_milestone_title'.tr,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppTextField(
            label: 'budget_plans.milestone_title'.tr,
            hint: 'budget_plans.milestone_title_hint'.tr,
            controller: titleCtrl,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'budget_plans.target_amount'.tr,
            hint: '0.00',
            prefixText: 'RM ',
            controller: amountCtrl,
            keyboardType: AppTextFieldKeyboardType.decimal,
          ),
        ],
      ),
      actions: [
        DialogAction(
          text: 'general.cancel'.tr,
          onPressed: () => Navigator.pop(context),
        ),
        DialogAction(
          text: 'general.add'.tr,
          isPrimary: true,
          onPressed: () {
            final title = titleCtrl.text.trim();
            final amount = double.tryParse(amountCtrl.text) ?? 0.0;
            if (title.isNotEmpty && amount > 0) {
              callbacks.onAddMilestone?.call(title, amount);
              Navigator.pop(context);
            }
          },
        ),
      ],
    );
  }
}

class _MilestoneTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> milestone;
  final VoidCallback onDelete;

  const _MilestoneTile({
    super.key,
    required this.index,
    required this.milestone,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final title = (milestone['title'] as String?) ?? '';
    final amount = ((milestone['targetAmount'] ?? 0.0) as double);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            '${index + 1}',
            style: AppTextStyles.caption.copyWith(color: AppColors.primary),
          ),
        ),
        title: Text(title, style: AppTextStyles.bodySemiBold),
        subtitle: Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: onDelete,
        ),
      ),
    );
  }
}

// ── Step 4: Review ────────────────────────────────────────────────────────────

class StepReview extends StatelessWidget {
  final BudgetPlanFormData data;
  final bool showMilestones;

  const StepReview({super.key, required this.data, this.showMilestones = true});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.step_review'.tr,
            subtitle: 'budget_plans.review_subtitle'.tr,
            showDivider: true,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Plan summary card
          AppCard(
            child: Column(
              children: [
                // Accent color band + name header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Color(data.accentColorValue).withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Color(data.accentColorValue),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          data.name.isNotEmpty
                              ? data.name
                              : 'budget_plans.unnamed'.tr,
                          style: AppTextStyles.bodySemiBold,
                        ),
                      ),
                      _CategoryBadge(category: data.category),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _ReviewRow(
                  icon: Icons.flag_outlined,
                  label: 'budget_plans.target_amount'.tr,
                  value: 'RM ${data.targetAmount.toStringAsFixed(2)}',
                  highlight: true,
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _ReviewRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'budget_plans.start_date_label'.tr,
                  value: DateFormat('MMM d, y').format(data.startDate),
                ),
                const Divider(height: 1, indent: AppSpacing.lg),
                _ReviewRow(
                  icon: Icons.event_outlined,
                  label: 'budget_plans.target_date_label'.tr,
                  value: DateFormat('MMM d, y').format(data.endDate),
                ),
                if (data.description.isNotEmpty) ...[
                  const Divider(height: 1, indent: AppSpacing.lg),
                  _ReviewRow(
                    icon: Icons.notes_outlined,
                    label: 'budget_plans.description'.tr,
                    value: data.description,
                  ),
                ],
              ],
            ),
          ),

          // Milestones summary
          if (showMilestones && data.milestones.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            SectionHeaderCompact(title: 'budget_plans.step_milestones'.tr),
            const SizedBox(height: AppSpacing.sm),
            ...data.milestones.asMap().entries.map(
              (e) => _MilestoneSummaryTile(
                index: e.key,
                milestone: e.value,
                accentColor: Color(data.accentColorValue),
              ),
            ),
          ],

          if (showMilestones && data.milestones.isEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'budget_plans.no_milestones_review'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  const _ReviewRow({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppIconSize.sm, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(
            value,
            style: highlight
                ? AppTextStyles.bodySemiBold.copyWith(
                    color: AppColors.primary,
                    fontSize: 16,
                  )
                : AppTextStyles.bodySemiBold,
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final BudgetPlanCategory category;

  const _CategoryBadge({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(category.iconCode, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(category.displayName, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

class _MilestoneSummaryTile extends StatelessWidget {
  final int index;
  final Map<String, dynamic> milestone;
  final Color accentColor;

  const _MilestoneSummaryTile({
    required this.index,
    required this.milestone,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final title = (milestone['title'] as String?) ?? '';
    final amount = ((milestone['targetAmount'] ?? 0.0) as double);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(title, style: AppTextStyles.bodyMedium)),
          Text(
            'RM ${amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodySemiBold,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIZARD CHROME (Step Bar + Nav Bar)
// ─────────────────────────────────────────────────────────────────────────────

/// Responsive step indicator.
/// - Narrow screens (< 380 px logical): compact numbered-dot mode.
/// - Wider screens: full label strip with connecting progress line.
class WizardStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const WizardStepBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 380;
        return compact
            ? _CompactStepBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                accentColor: accentColor,
                stepLabels: stepLabels,
              )
            : _FullStepBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                accentColor: accentColor,
                stepLabels: stepLabels,
              );
      },
    );
  }
}

/// Full-width step bar with labels and animated progress line.
class _FullStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const _FullStepBar({
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        0,
      ),
      child: Column(
        children: [
          // ── Circle row with connectors ───────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final done = i < currentStep;
              final active = i == currentStep;
              return Expanded(
                child: Row(
                  children: [
                    _StepCircle(
                      index: i,
                      done: done,
                      active: active,
                      accentColor: accentColor,
                    ),
                    if (i < totalSteps - 1)
                      Expanded(
                        child: _AnimatedConnector(
                          filled: i < currentStep,
                          accentColor: accentColor,
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.xs),
          // ── Label row ────────────────────────────────────────────────
          Row(
            children: List.generate(totalSteps, (i) {
              final active = i <= currentStep;
              // Each label sits under its circle; the connector has no label.
              return Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        stepLabels[i].tr,
                        style: AppTextStyles.caption.copyWith(
                          color: active
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (i < totalSteps - 1) const Spacer(),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _StepCircle extends StatelessWidget {
  final int index;
  final bool done;
  final bool active;
  final Color accentColor;

  const _StepCircle({
    required this.index,
    required this.done,
    required this.active,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Widget child;

    if (done) {
      bg = accentColor;
      child = const Icon(Icons.check, color: Colors.white, size: 14);
    } else if (active) {
      bg = accentColor;
      child = Text(
        '${index + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    } else {
      bg = AppColors.divider;
      child = Text(
        '${index + 1}',
        style: TextStyle(
          color: AppColors.textHint,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: active ? 34 : 28,
      height: active ? 34 : 28,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Center(child: child),
    );
  }
}

class _AnimatedConnector extends StatelessWidget {
  final bool filled;
  final Color accentColor;

  const _AnimatedConnector({required this.filled, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: filled ? accentColor : AppColors.divider,
    );
  }
}

/// Compact dot bar for very narrow screens.
class _CompactStepBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final Color accentColor;
  final List<String> stepLabels;

  const _CompactStepBar({
    required this.currentStep,
    required this.totalSteps,
    required this.accentColor,
    required this.stepLabels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Dot strip
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (i) {
              final active = i == currentStep;
              final done = i < currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: active ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (active || done) ? accentColor : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              stepLabels[currentStep].tr,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${currentStep + 1}/$totalSteps',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared bottom navigation bar for both wizards.
class WizardNavBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isLoading;
  final Color accentColor;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final String finalLabel;

  const WizardNavBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isLoading,
    required this.accentColor,
    required this.onBack,
    required this.onNext,
    required this.finalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return _BottomNavBar(
      child: Row(
        children: [
          if (currentStep > 0) ...[
            Expanded(
              child: AppButton.secondary(
                label: 'general.back'.tr,
                onPressed: isLoading ? null : onBack,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            flex: currentStep > 0 ? 1 : 2,
            child: AppButton.primary(
              label: currentStep == totalSteps - 1
                  ? finalLabel
                  : 'general.next'.tr,
              isLoading: isLoading,
              onPressed: isLoading ? null : onNext,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Misc shared widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _AmountField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Text(
            'RM',
            style: AppTextStyles.amountMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: AppTextStyles.amountMedium,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String labelKey;
  final DateTime date;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.labelKey,
    required this.date,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelKey.tr, style: AppTextStyles.bodySemiBold),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: date,
              firstDate: firstDate,
              lastDate: lastDate,
            );
            if (picked != null) onChanged(picked);
          },
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: AppColors.textSecondary,
                  size: AppIconSize.md,
                ),
                const SizedBox(width: AppSpacing.lg),
                Text(
                  DateFormat('MMM d, y').format(date),
                  style: AppTextStyles.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final Widget child;

  const _BottomNavBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            AppButton.primary(label: 'general.retry'.tr, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
