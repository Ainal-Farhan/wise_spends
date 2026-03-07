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
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Create Budget Plan Screen - 3-step wizard (Pure BLoC)
class CreateBudgetPlanScreen extends StatelessWidget {
  const CreateBudgetPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CreateBudgetPlanFormBloc()
            ..add(const InitializeCreateBudgetPlanForm()),
      child: const _CreateBudgetPlanScreenContent(),
    );
  }
}

class _CreateBudgetPlanScreenContent extends StatefulWidget {
  const _CreateBudgetPlanScreenContent();

  @override
  State<_CreateBudgetPlanScreenContent> createState() =>
      _CreateBudgetPlanScreenContentState();
}

class _CreateBudgetPlanScreenContentState
    extends State<_CreateBudgetPlanScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _targetAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('budget_plans.create')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<CreateBudgetPlanFormBloc, CreateBudgetPlanFormState>(
        listener: (context, state) {
          if (state is CreateBudgetPlanFormReady) {
            // Update controllers when state changes
            if (_nameController.text != state.name) {
              _nameController.text = state.name;
            }
            if (_targetAmountController.text != state.targetAmount.toString()) {
              _targetAmountController.text = state.targetAmount.toString();
            }
          }
        },
        builder: (context, state) {
          if (state is! CreateBudgetPlanFormReady) {
            return const Center(child: CircularProgressIndicator());
          }

          final formState = state;

          return Column(
            children: [
              // Step indicator
              _buildStepIndicator(loc, formState.currentStep),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: IndexedStack(
                    index: formState.currentStep,
                    children: [
                      _buildStep1PlanBasics(loc, formState),
                      _buildStep2FinancialGoals(loc, formState),
                      _buildStep3Milestones(loc, formState),
                    ],
                  ),
                ),
              ),

              // Navigation buttons
              _buildNavigationButtons(loc, formState.currentStep),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStepIndicator(LocalizationService loc, int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicatorItem(
            0,
            loc.get('budget_plans.step_basics'),
            currentStep,
          ),
          const SizedBox(width: 8),
          _buildStepIndicatorItem(
            1,
            loc.get('budget_plans.step_financial'),
            currentStep,
          ),
          const SizedBox(width: 8),
          _buildStepIndicatorItem(
            2,
            loc.get('budget_plans.step_milestones'),
            currentStep,
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicatorItem(int step, String label, int currentStep) {
    final isActive = step <= currentStep;

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
                '${step + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : AppColors.textHint,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.textPrimary : AppColors.textHint,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1PlanBasics(
    LocalizationService loc,
    CreateBudgetPlanFormReady formState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Input
          Text(
            loc.get('budget_plans.plan_name'),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Plan name',
            hint: 'e.g., Emergency Fund, Vacation',
            controller: _nameController,
            onChanged: (value) {
              context.read<CreateBudgetPlanFormBloc>().add(
                ChangePlanName(value),
              );
            },
          ),
          const SizedBox(height: 24),

          // Description Input
          Text(
            loc.get('budget_plans.description'),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Description',
            hint: 'Optional description',
            controller: _descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Category Selection
          Text(
            loc.get('budget_plans.category'),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BudgetPlanCategory.values.map((category) {
              final isSelected = formState.category == category;
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<CreateBudgetPlanFormBloc>().add(
                    SelectBudgetPlanCategory(category),
                  );
                },
                avatar: Text(category.iconCode),
                selectedColor: Color(
                  formState.accentColorValue,
                ).withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Color Selection
          Text(
            loc.get('budget_plans.accent_color'),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildColorOption(AppColors.primary, formState),
              const SizedBox(width: 8),
              _buildColorOption(AppColors.secondary, formState),
              const SizedBox(width: 8),
              _buildColorOption(AppColors.tertiary, formState),
              const SizedBox(width: 8),
              _buildColorOption(AppColors.warning, formState),
              const SizedBox(width: 8),
              _buildColorOption(AppColors.info, formState),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color, CreateBudgetPlanFormReady formState) {
    final isSelected = formState.accentColorValue == color.toARGB32();

    return GestureDetector(
      onTap: () {
        context.read<CreateBudgetPlanFormBloc>().add(
          ChangeAccentColor(color.toARGB32()),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _buildStep2FinancialGoals(
    LocalizationService loc,
    CreateBudgetPlanFormReady formState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Amount
          Text(
            loc.get('budget_plans.target_amount'),
            style: AppTextStyles.bodySemiBold,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _targetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.amountMedium,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    onChanged: (value) {
                      final amount = double.tryParse(value) ?? 0.0;
                      context.read<CreateBudgetPlanFormBloc>().add(
                        ChangeTargetAmount(amount),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Start Date
          Text('budget_plans.start_date_label'.tr, style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: formState.startDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                context.read<CreateBudgetPlanFormBloc>().add(
                  ChangeStartDate(picked),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMM d, y').format(formState.startDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Target Date
          Text('budget_plans.target_date_label'.tr, style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: formState.endDate,
                firstDate: formState.startDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                context.read<CreateBudgetPlanFormBloc>().add(
                  ChangeEndDate(picked),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    DateFormat('MMM d, y').format(formState.endDate),
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Milestones(
    LocalizationService loc,
    CreateBudgetPlanFormReady formState,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('budget_plans.milestones_optional'.tr, style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          Text(
            'Break down your goal into smaller milestones',
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: 16),

          // Milestones List
          ...formState.milestones.asMap().entries.map((entry) {
            final milestone = entry.value;
            return ListTile(
              title: Text(milestone['title'] ?? ''),
              subtitle: Text(
                'RM ${(milestone['targetAmount'] ?? 0.0).toStringAsFixed(2)}',
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  // Remove milestone (would need RemoveMilestone event)
                },
              ),
            );
          }),

          const SizedBox(height: 16),

          // Add Milestone Button
          AppButton.secondary(
            label: 'Add Milestone',
            icon: Icons.add,
            onPressed: () => _showAddMilestoneDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(LocalizationService loc, int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          if (currentStep > 0)
            Expanded(
              child: AppButton.secondary(
                label: 'Back',
                onPressed: () {
                  context.read<CreateBudgetPlanFormBloc>().add(
                    ChangeCurrentStep(currentStep - 1),
                  );
                },
              ),
            ),
          if (currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: currentStep > 0 ? 1 : 2,
            child: AppButton.primary(
              label: currentStep == 2 ? 'Create Plan' : 'Next',
              onPressed: () {
                if (currentStep < 2) {
                  context.read<CreateBudgetPlanFormBloc>().add(
                    ChangeCurrentStep(currentStep + 1),
                  );
                } else {
                  _submitForm();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('budget_plans.add_milestone_title'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
              label: 'Title',
              hint: 'e.g., 25% Complete',
              controller: titleController,
            ),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Target Amount',
              hint: '0.00',
              prefixText: 'RM ',
              controller: amountController,
              keyboardType: AppTextFieldKeyboardType.decimal,
            ),
          ],
        ),
        actions: [
          AppButton.text(
            label: 'Cancel',
            onPressed: () => Navigator.pop(context),
          ),
          AppButton.primary(
            label: 'Add',
            onPressed: () {
              final title = titleController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

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

  void _submitForm() {
    final bloc = context.read<CreateBudgetPlanFormBloc>();
    final state = bloc.state;
    if (state is! CreateBudgetPlanFormReady) return;

    if (state.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('budget_plans.enter_plan_name'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (state.targetAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('budget_plans.enter_target'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Navigate back and reload
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budget_plans.created'.tr),
        backgroundColor: AppColors.success,
      ),
    );

    context.read<BudgetPlanListBloc>().add(LoadBudgetPlans());
  }
}
