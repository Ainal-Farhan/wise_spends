import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/domain/entities/budget_plan_enums.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/create_budget_plan_form_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/create_budget_plan_form_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/create_budget_plan_form_state.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/edit_budget_plan_form_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/edit_budget_plan_form_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/edit_budget_plan_form_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog_utils.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Accent colour palette
// ─────────────────────────────────────────────────────────────────────────────

class _AccentColors {
  static List<int> getArgbValues(BuildContext context) {
    return [
      Theme.of(context).colorScheme.primary.toARGB32(),
      Theme.of(context).colorScheme.secondary.toARGB32(),
      Theme.of(context).colorScheme.tertiary.toARGB32(),
      Theme.of(context).colorScheme.tertiary.toARGB32(),
      Theme.of(context).colorScheme.primary.toARGB32(),
    ];
  }
}

/// Immutable snapshot of the common form fields used by every step widget.
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

  factory BudgetPlanFormData.fromEdit(
    BuildContext context,
    EditBudgetPlanFormReady s,
  ) => BudgetPlanFormData(
    name: s.name,
    description: s.description,
    category: s.category,
    targetAmount: s.targetAmount,
    startDate: s.startDate,
    endDate: s.endDate,
    accentColorValue: Theme.of(context).colorScheme.primary.toARGB32(),
    milestones: const [],
    currentStep: s.currentStep,
    isLoading: s.isLoading,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Callback interface
// ─────────────────────────────────────────────────────────────────────────────

class BudgetPlanFormCallbacks {
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<BudgetPlanCategory> onCategoryChanged;
  final ValueChanged<int> onAccentColorChanged;
  final ValueChanged<double> onTargetAmountChanged;
  final ValueChanged<double> onCurrentAmountChanged;
  final ValueChanged<DateTime> onStartDateChanged;
  final ValueChanged<DateTime> onEndDateChanged;
  final void Function(String title, double amount)? onAddMilestone;
  final ValueChanged<int>? onRemoveMilestone;

  const BudgetPlanFormCallbacks({
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onCategoryChanged,
    required this.onAccentColorChanged,
    required this.onTargetAmountChanged,
    required this.onCurrentAmountChanged,
    required this.onStartDateChanged,
    required this.onEndDateChanged,
    this.onAddMilestone,
    this.onRemoveMilestone,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// CREATE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('budget_plans.create'.tr),
        leading: IconButton(
          icon: Icon(Icons.close),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
            );
            Navigator.pop(context);
          } else if (state is CreateBudgetPlanFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
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
                  ],
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
      onDescriptionChanged: (v) {}, // Description not tracked in create
      onCategoryChanged: (c) => bloc.add(SelectBudgetPlanCategory(c)),
      onAccentColorChanged: (v) => bloc.add(ChangeAccentColor(v)),
      onTargetAmountChanged: (v) => bloc.add(ChangeTargetAmount(v)),
      onCurrentAmountChanged: (v) => bloc.add(ChangeCurrentAmount(v)),
      onStartDateChanged: (d) => bloc.add(ChangeStartDate(d)),
      onEndDateChanged: (d) => bloc.add(ChangeEndDate(d)),
      onAddMilestone: (t, a) => bloc.add(AddMilestone(t, a)),
      onRemoveMilestone: (i) => bloc.add(RemoveMilestone(i)),
    );
  }

  void _handleNext(BuildContext context, CreateBudgetPlanFormReady state) {
    if (state.currentStep < _totalSteps - 1) {
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
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EDIT SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      appBar: AppBar(
        title: Text('budget_plans.edit'.tr),
        leading: IconButton(
          icon: Icon(Icons.close),
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
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
              ),
            );
            // Close the edit screen after a short delay
            Future.delayed(const Duration(milliseconds: 500), () {
              if (context.mounted) {
                Navigator.pop(context);
              }
            });
          } else if (state is EditBudgetPlanFormError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EditBudgetPlanFormLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EditBudgetPlanFormReady) {
            final data = BudgetPlanFormData.fromEdit(context, state);
            final callbacks = _buildCallbacks(context);

            return Column(
              children: [
                WizardStepBar(
                  currentStep: state.currentStep,
                  totalSteps: _totalSteps,
                  accentColor: Theme.of(context).colorScheme.primary,
                  stepLabels: _stepLabels,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AnimatedSwitcher(
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
                    ],
                  ),
                ),
                WizardNavBar(
                  currentStep: state.currentStep,
                  totalSteps: _totalSteps,
                  isLoading: state.isLoading,
                  accentColor: Theme.of(context).colorScheme.primary,
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
      onNameChanged: (v) => bloc.add(EditChangePlanName(v)),
      onDescriptionChanged: (v) => bloc.add(EditChangeDescription(v)),
      onCategoryChanged: (c) => bloc.add(EditSelectCategory(c)),
      onAccentColorChanged: (v) => bloc.add(EditChangeAccentColor(v)),
      onTargetAmountChanged: (v) => bloc.add(EditChangeTargetAmount(v)),
      onCurrentAmountChanged: (v) => bloc.add(EditChangeCurrentAmount(v)),
      onStartDateChanged: (d) => bloc.add(EditChangeStartDate(d)),
      onEndDateChanged: (d) => bloc.add(EditChangeEndDate(d)),
      onAddMilestone: null,
      onRemoveMilestone: null,
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'budget_plans.step_basics'.tr,
            subtitle: 'budget_plans.step_basics_subtitle'.tr,
            icon: Icons.edit_note_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppTextField(
            label: 'budget_plans.plan_name'.tr,
            hint: 'budget_plans.plan_name_hint'.tr,
            controller: nameCtrl,
            onChanged: callbacks.onNameChanged,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'budget_plans.description'.tr,
            hint: 'budget_plans.description_hint'.tr,
            controller: descCtrl,
            maxLines: 3,
            onChanged: callbacks.onDescriptionChanged,
          ),
          const SizedBox(height: AppSpacing.lg),
          _FormSectionLabel(label: 'budget_plans.category'.tr),
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
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            }).toList(),
          ),
          if (showAccentColor) ...[
            const SizedBox(height: AppSpacing.lg),
            _FormSectionLabel(label: 'budget_plans.accent_color'.tr),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _AccentColors.getArgbValues(context).map((colorValue) {
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'budget_plans.step_financial'.tr,
            subtitle: 'budget_plans.step_financial_subtitle'.tr,
            icon: Icons.account_balance_wallet_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          _FormSectionLabel(label: 'budget_plans.target_amount'.tr),
          const SizedBox(height: AppSpacing.sm),
          _AmountField(
            controller: targetCtrl,
            onChanged: (v) =>
                callbacks.onTargetAmountChanged(double.tryParse(v) ?? 0.0),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (showStartDate) ...[
            _DateField(
              labelKey: 'budget_plans.start_date_label',
              date: data.startDate,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              onChanged: callbacks.onStartDateChanged,
            ),
            const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'budget_plans.step_milestones'.tr,
            subtitle: 'budget_plans.milestones_optional'.tr,
            icon: Icons.flag_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (data.milestones.isEmpty)
            _EmptyMilestonesPlaceholder()
          else
            ...data.milestones.asMap().entries.map(
              (e) => _MilestoneTile(
                key: ValueKey('milestone-${e.key}'),
                index: e.key,
                milestone: e.value,
                onDelete: () => callbacks.onRemoveMilestone?.call(e.key),
              ),
            ),
          const SizedBox(height: AppSpacing.md),
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

class _EmptyMilestonesPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline,
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.flag_outlined,
            size: 40,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'budget_plans.no_milestones_yet'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(
            '${index + 1}',
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        title: Text(title, style: AppTextStyles.bodySemiBold),
        subtitle: Text(
          'RM ${amount.toStringAsFixed(2)}',
          style: AppTextStyles.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
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
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepHeader(
            title: 'budget_plans.step_review'.tr,
            subtitle: 'budget_plans.review_subtitle'.tr,
            icon: Icons.checklist_outlined,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Plan summary card
          AppCard(
            child: Column(
              children: [
                // Accent color band + name header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: Color(data.accentColorValue).withValues(alpha: 0.12),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
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
            const SizedBox(height: AppSpacing.lg),
            _FormSectionLabel(label: 'budget_plans.step_milestones'.tr),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              'budget_plans.no_milestones_review'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
          Icon(
            icon,
            size: AppIconSize.sm,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: AppTextStyles.caption)),
          Text(
            value,
            style: highlight
                ? AppTextStyles.bodySemiBold.copyWith(
                    color: Theme.of(context).colorScheme.primary,
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
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
/// - Narrow screens (< 400 px logical): compact pill-dot mode.
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
        // Calculate if there's enough space to show full labels.
        // Approximately 72px per step needed for labels; fall back to compact.
        final enoughWidth = constraints.maxWidth >= totalSteps * 72;
        return enoughWidth
            ? _FullStepBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
                accentColor: accentColor,
                stepLabels: stepLabels,
              )
            : _CompactStepBar(
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
///
/// Each step is a Column(circle + label) interleaved with connector spacers,
/// so the label height never pushes content down below the bar.
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
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      // Each step = Column(circle + label), connectors between them as Expanded.
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(totalSteps * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector between two step nodes — nudged down to align with circles
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: _AnimatedConnector(
                  filled: (i ~/ 2) < currentStep,
                  accentColor: accentColor,
                ),
              ),
            );
          }

          final stepIndex = i ~/ 2;
          final done = stepIndex < currentStep;
          final active = stepIndex == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _StepCircle(
                index: stepIndex,
                done: done,
                active: active,
                accentColor: accentColor,
              ),
              const SizedBox(height: AppSpacing.xs),
              SizedBox(
                width: 70,
                child: Text(
                  stepLabels[stepIndex].tr,
                  style: AppTextStyles.caption.copyWith(
                    color: (active || done)
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.outline,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }),
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
      child = Icon(Icons.check, color: Colors.white, size: 14);
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
      bg = Theme.of(context).colorScheme.outline;
      child = Text(
        '${index + 1}',
        style: TextStyle(
          color: Theme.of(context).colorScheme.outline,
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
      color: filled ? accentColor : Theme.of(context).colorScheme.outline,
    );
  }
}

/// Compact pill-dot bar for narrow screens — shows current step label in full.
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
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          // Progress pill strip
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalSteps, (i) {
              final active = i == currentStep;
              final done = i < currentStep;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 5),
                width: active ? 22 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: (active || done)
                      ? accentColor
                      : Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(width: AppSpacing.md),
          // Current step label — expand and allow wrapping
          Expanded(
            child: Text(
              stepLabels[currentStep].tr,
              style: AppTextStyles.caption.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              // Let it wrap to show full text on narrow screens
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${currentStep + 1}/$totalSteps',
            style: AppTextStyles.caption.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
// Internal shared widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Compact step header that replaces the heavy [SectionHeader] inside each
/// step's scroll view. Uses an icon + title + subtitle pattern with minimal
/// vertical footprint.
class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _StepHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.h3),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Small section label used within a step's form fields.
class _FormSectionLabel extends StatelessWidget {
  final String label;

  const _FormSectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label, style: AppTextStyles.bodySemiBold);
  }
}

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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Text(
            'RM',
            style: AppTextStyles.amountMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
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
            ? Icon(Icons.check, color: Colors.white, size: 20)
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
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
