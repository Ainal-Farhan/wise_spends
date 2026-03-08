// ─────────────────────────────────────────────────────────────────────────────
// create_budget_plan_screen.dart
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
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// 3-step wizard to create a new budget plan.
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
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _targetCtrl = TextEditingController();

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
      appBar: AppBar(
        title: Text('budget_plans.create'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CreateBudgetPlanFormBloc, CreateBudgetPlanFormState>(
        listener: (context, state) {
          // Keep name controller in sync for the pre-fill path.
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
          return Column(
            children: [
              _WizardStepBar(currentStep: state.currentStep),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: IndexedStack(
                    index: state.currentStep,
                    children: [
                      _Step1Basics(
                        state: state,
                        nameCtrl: _nameCtrl,
                        descCtrl: _descCtrl,
                      ),
                      _Step2Financial(state: state, targetCtrl: _targetCtrl),
                      _Step3Milestones(state: state),
                    ],
                  ),
                ),
              ),
              _WizardNavBar(
                currentStep: state.currentStep,
                isLoading: state.isLoading,
                onBack: () => context.read<CreateBudgetPlanFormBloc>().add(
                  ChangeCurrentStep(state.currentStep - 1),
                ),
                onNext: () => state.currentStep < 2
                    ? context.read<CreateBudgetPlanFormBloc>().add(
                        ChangeCurrentStep(state.currentStep + 1),
                      )
                    : _submit(state),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit(CreateBudgetPlanFormReady state) {
    // Client-side validation only — no DB call here.
    if (state.name.trim().isEmpty) {
      _showError('budget_plans.enter_plan_name'.tr);
      return;
    }
    if (state.targetAmount <= 0) {
      _showError('budget_plans.enter_target'.tr);
      return;
    }

    // Delegate the actual save to the bloc.
    context.read<CreateBudgetPlanFormBloc>().add(const SaveCreateBudgetPlan());
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// =============================================================================
// Step 1 — Basics
// =============================================================================

class _Step1Basics extends StatelessWidget {
  final CreateBudgetPlanFormReady state;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;

  const _Step1Basics({
    required this.state,
    required this.nameCtrl,
    required this.descCtrl,
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
            onChanged: (v) =>
                context.read<CreateBudgetPlanFormBloc>().add(ChangePlanName(v)),
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
              final isSelected = state.category == cat;
              return FilterChip(
                label: Text(cat.displayName),
                selected: isSelected,
                avatar: Text(cat.iconCode),
                onSelected: (_) => context.read<CreateBudgetPlanFormBloc>().add(
                  SelectBudgetPlanCategory(cat),
                ),
                selectedColor: Color(
                  state.accentColorValue,
                ).withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.xxl),

          SectionHeaderCompact(title: 'budget_plans.accent_color'.tr),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children:
                [
                      AppColors.primary,
                      AppColors.secondary,
                      AppColors.tertiary,
                      AppColors.warning,
                      AppColors.info,
                    ]
                    .map(
                      (color) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: _ColorSwatch(
                          color: color,
                          isSelected:
                              state.accentColorValue == color.toARGB32(),
                          onTap: () => context
                              .read<CreateBudgetPlanFormBloc>()
                              .add(ChangeAccentColor(color.toARGB32())),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 2 — Financial goals
// =============================================================================

class _Step2Financial extends StatelessWidget {
  final CreateBudgetPlanFormReady state;
  final TextEditingController targetCtrl;

  const _Step2Financial({required this.state, required this.targetCtrl});

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

          // Target amount
          Text(
            'budget_plans.target_amount'.tr,
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
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
                    controller: targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.amountMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (v) => context
                        .read<CreateBudgetPlanFormBloc>()
                        .add(ChangeTargetAmount(double.tryParse(v) ?? 0.0)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Start date
          _DateField(
            labelKey: 'budget_plans.start_date_label',
            date: state.startDate,
            firstDate: DateTime(2020),
            lastDate: DateTime(2100),
            onChanged: (d) => context.read<CreateBudgetPlanFormBloc>().add(
              ChangeStartDate(d),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // End date
          _DateField(
            labelKey: 'budget_plans.target_date_label',
            date: state.endDate,
            firstDate: state.startDate,
            lastDate: DateTime(2100),
            onChanged: (d) =>
                context.read<CreateBudgetPlanFormBloc>().add(ChangeEndDate(d)),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Step 3 — Milestones
// =============================================================================

class _Step3Milestones extends StatelessWidget {
  final CreateBudgetPlanFormReady state;

  const _Step3Milestones({required this.state});

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

          if (state.milestones.isEmpty)
            Center(
              child: Text(
                'budget_plans.no_milestones_yet'.tr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),

          ...state.milestones.map(
            (m) => ListTile(
              title: Text((m['title'] as String?) ?? ''),
              subtitle: Text(
                'RM ${((m['targetAmount'] ?? 0.0) as double).toStringAsFixed(2)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {},
              ),
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

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('budget_plans.add_milestone_title'.tr),
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
          AppButton.text(
            label: 'general.cancel'.tr,
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.primary(
            label: 'general.add'.tr,
            onPressed: () {
              final title = titleCtrl.text;
              final amount = double.tryParse(amountCtrl.text) ?? 0.0;
              if (title.isNotEmpty && amount > 0) {
                context.read<CreateBudgetPlanFormBloc>().add(
                  AddMilestone(title, amount),
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }
}

/// 3-step wizard to edit an existing budget plan.
class EditBudgetPlanScreen extends StatelessWidget {
  final String planUuid;

  const EditBudgetPlanScreen({super.key, required this.planUuid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              EditBudgetPlanFormBloc()..add(InitializeEditBudgetPlan(planUuid)),
        ),
      ],
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

  /// Tracks whether controllers have been seeded from the loaded state.
  /// Without this guard the listener would overwrite user edits on every
  /// subsequent state emission (e.g. after changing a category chip).
  bool _controllersSynced = false;

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
      appBar: AppBar(
        title: Text('budget_plans.edit'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<EditBudgetPlanFormBloc, EditBudgetPlanFormState>(
        listener: (context, state) {
          // ── Sync controllers once when the plan data first arrives ─────────
          // This is the fix for controllers showing empty strings after load.
          // We only do it once (_controllersSynced guard) so user edits are
          // not overwritten by subsequent Ready emissions (e.g. chip taps).
          if (state is EditBudgetPlanFormReady && !_controllersSynced) {
            _controllersSynced = true;
            // Only update if different to avoid unnecessary cursor resets.
            if (_nameCtrl.text != state.name) _nameCtrl.text = state.name;
            if (_descCtrl.text != state.description) {
              _descCtrl.text = state.description;
            }
            final targetStr = state.targetAmount > 0
                ? state.targetAmount.toStringAsFixed(2)
                : '';
            if (_targetCtrl.text != targetStr) _targetCtrl.text = targetStr;
          }

          // ── Terminal states ─────────────────────────────────────────────────
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
            return Column(
              children: [
                _WizardStepBar(currentStep: state.currentStep, stepCount: 3),
                Expanded(
                  child: IndexedStack(
                    index: state.currentStep,
                    children: [
                      _EditStep1(
                        state: state,
                        nameCtrl: _nameCtrl,
                        descCtrl: _descCtrl,
                      ),
                      _EditStep2(state: state, targetCtrl: _targetCtrl),
                      _EditStep3Review(state: state),
                    ],
                  ),
                ),
                _EditNavBar(state: state),
              ],
            );
          }
          // EditBudgetPlanFormError with no prior Ready state — show inline error.
          if (state is EditBudgetPlanFormError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppButton.primary(
                      label: 'general.retry'.tr,
                      onPressed: () => context
                          .read<EditBudgetPlanFormBloc>()
                          .add(InitializeEditBudgetPlan(widget.planUuid)),
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EditStep1 extends StatelessWidget {
  final EditBudgetPlanFormReady state;
  final TextEditingController nameCtrl;
  final TextEditingController descCtrl;

  const _EditStep1({
    required this.state,
    required this.nameCtrl,
    required this.descCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.edit_basics'.tr,
            subtitle: 'budget_plans.edit_basics_subtitle'.tr,
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppTextField(
            label: 'budget_plans.plan_name_label'.tr,
            hint: 'budget_plans.plan_name_hint'.tr,
            controller: nameCtrl,
          ),
          const SizedBox(height: AppSpacing.lg),

          AppTextField(
            label: 'budget_plans.description_label'.tr,
            hint: 'budget_plans.description_hint'.tr,
            controller: descCtrl,
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.xxl),

          SectionHeaderCompact(title: 'budget_plans.category_label'.tr),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: BudgetPlanCategory.values.map((cat) {
              final isSelected = state.category == cat;
              return FilterChip(
                label: Text(cat.displayName),
                selected: isSelected,
                onSelected: (_) => context.read<EditBudgetPlanFormBloc>().add(
                  EditSelectCategory(cat),
                ),
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _EditStep2 extends StatelessWidget {
  final EditBudgetPlanFormReady state;
  final TextEditingController targetCtrl;

  const _EditStep2({required this.state, required this.targetCtrl});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.edit_financial'.tr,
            subtitle: 'budget_plans.edit_financial_subtitle'.tr,
          ),
          const SizedBox(height: AppSpacing.xxl),

          AppTextField(
            label: 'budget_plans.target_amount_label'.tr,
            hint: '0.00',
            prefixText: 'RM ',
            controller: targetCtrl,
            keyboardType: AppTextFieldKeyboardType.decimal,
          ),
          const SizedBox(height: AppSpacing.lg),

          _DateField(
            labelKey: 'budget_plans.target_date_label',
            date: state.endDate,
            firstDate: state.startDate,
            lastDate: DateTime(2100),
            onChanged: (d) => context.read<EditBudgetPlanFormBloc>().add(
              EditChangeEndDate(d),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditStep3Review extends StatelessWidget {
  final EditBudgetPlanFormReady state;

  const _EditStep3Review({required this.state});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'budget_plans.review'.tr,
            subtitle: 'budget_plans.review_subtitle'.tr,
            showDivider: true,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: Column(
              children: [
                _ReviewRow('general.name'.tr, state.name),
                const Divider(height: 1),
                _ReviewRow(
                  'budget_plans.category_label'.tr,
                  state.category.displayName,
                ),
                const Divider(height: 1),
                _ReviewRow(
                  'budget_plans.target_amount_label'.tr,
                  'RM ${state.targetAmount.toStringAsFixed(2)}',
                ),
                const Divider(height: 1),
                _ReviewRow(
                  'budget_plans.target_date_label'.tr,
                  DateFormat('MMM d, y').format(state.endDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.bodySemiBold),
        ],
      ),
    );
  }
}

class _EditNavBar extends StatelessWidget {
  final EditBudgetPlanFormReady state;

  const _EditNavBar({required this.state});

  @override
  Widget build(BuildContext context) {
    return _BottomNavBar(
      child: Row(
        children: [
          if (state.currentStep > 0) ...[
            Expanded(
              child: AppButton.secondary(
                label: 'general.back'.tr,
                onPressed: () => context.read<EditBudgetPlanFormBloc>().add(
                  EditChangeStep(state.currentStep - 1),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
          ],
          Expanded(
            flex: state.currentStep > 0 ? 1 : 2,
            child: AppButton.primary(
              label: state.currentStep == 2
                  ? 'budget_plans.save_changes'.tr
                  : 'general.next'.tr,
              isLoading: state.isLoading,
              onPressed: state.isLoading
                  ? null
                  : () {
                      if (state.currentStep < 2) {
                        context.read<EditBudgetPlanFormBloc>().add(
                          EditChangeStep(state.currentStep + 1),
                        );
                      } else {
                        context.read<EditBudgetPlanFormBloc>().add(
                          SaveEditBudgetPlan(),
                        );
                      }
                    },
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Shared wizard sub-widgets (used by both Create and Edit)
// =============================================================================

class _WizardStepBar extends StatelessWidget {
  final int currentStep;
  final int stepCount;

  const _WizardStepBar({required this.currentStep, this.stepCount = 3});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'budget_plans.step_basics'.tr,
      'budget_plans.step_financial'.tr,
      'budget_plans.step_milestones'.tr,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(stepCount, (i) {
          final isActive = i <= currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.divider,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textHint,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    labels[i],
                    style: AppTextStyles.caption.copyWith(
                      color: isActive
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                      fontWeight: isActive
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _WizardNavBar extends StatelessWidget {
  final int currentStep;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _WizardNavBar({
    required this.currentStep,
    required this.onBack,
    required this.onNext,
    this.isLoading = false,
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
              label: currentStep == 2
                  ? 'budget_plans.create'.tr
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
