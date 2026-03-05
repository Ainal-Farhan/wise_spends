import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_event.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_bloc.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_event.dart';
import 'package:wise_spends/presentation/blocs/edit_budget_plan_form/edit_budget_plan_form_state.dart';
import 'package:wise_spends/shared/components/components.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Edit Budget Plan Screen - Pure BLoC 3-step wizard
class EditBudgetPlanScreen extends StatelessWidget {
  final String planUuid;

  const EditBudgetPlanScreen({super.key, required this.planUuid});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              EditBudgetPlanFormBloc()..add(InitializeEditBudgetPlan(planUuid)),
        ),
      ],
      child: _EditBudgetPlanScreenContent(planUuid: planUuid),
    );
  }
}

class _EditBudgetPlanScreenContent extends StatelessWidget {
  final String planUuid;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetAmountController = TextEditingController();

  _EditBudgetPlanScreenContent({required this.planUuid});

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('budget_plans.edit')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<EditBudgetPlanFormBloc, EditBudgetPlanFormState>(
        listener: (context, state) {
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
          } else if (state is EditBudgetPlanFormReady) {
            return _buildWizard(
              context,
              loc,
              _formKey,
              _nameController,
              _descriptionController,
              _targetAmountController,
              state,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildWizard(
    BuildContext context,
    LocalizationService loc,
    GlobalKey<FormState> formKey,
    TextEditingController nameController,
    TextEditingController descriptionController,
    TextEditingController targetAmountController,
    EditBudgetPlanFormReady state,
  ) {
    return Column(
      children: [
        // Step indicator
        _buildStepIndicator(context, state),

        // Form content
        Expanded(
          child: Form(
            key: formKey,
            child: IndexedStack(
              index: 0, // Simplified for now
              children: [
                _buildStep1PlanBasics(
                  context,
                  loc,
                  state,
                  nameController,
                  descriptionController,
                ),
                _buildStep2FinancialGoals(
                  context,
                  loc,
                  state,
                  targetAmountController,
                ),
                _buildStep3Review(context, loc, state),
              ],
            ),
          ),
        ),

        // Navigation buttons
        _buildNavigationButtons(context, state),
      ],
    );
  }

  Widget _buildStepIndicator(
    BuildContext context,
    EditBudgetPlanFormReady state,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          _buildStepItem(0, 'Basics'),
          const SizedBox(width: 8),
          _buildStepItem(1, 'Financial'),
          const SizedBox(width: 8),
          _buildStepItem(2, 'Review'),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String label) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${step + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.caption.copyWith(
                fontWeight: FontWeight.w600,
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
    BuildContext context,
    LocalizationService loc,
    EditBudgetPlanFormReady state,
    TextEditingController nameController,
    TextEditingController descriptionController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Plan Name', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Name',
            hint: 'e.g., Emergency Fund',
            controller: nameController,
          ),
          const SizedBox(height: 16),
          Text('Description', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Description',
            hint: 'Optional description',
            controller: descriptionController,
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Category', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BudgetPlanCategory.values.map((category) {
              final isSelected = state.category == category;
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  context.read<EditBudgetPlanFormBloc>().add(
                    EditSelectCategory(category),
                  );
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2FinancialGoals(
    BuildContext context,
    LocalizationService loc,
    EditBudgetPlanFormReady state,
    TextEditingController targetAmountController,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Target Amount', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          AppTextField(
            label: 'Amount',
            hint: '0.00',
            controller: targetAmountController,
            prefixText: 'RM ',
            keyboardType: AppTextFieldKeyboardType.decimal,
          ),
          const SizedBox(height: 16),
          Text('Target Date', style: AppTextStyles.bodySemiBold),
          const SizedBox(height: 8),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: state.endDate,
                firstDate: state.startDate,
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                context.read<EditBudgetPlanFormBloc>().add(
                  EditChangeEndDate(picked),
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
                    DateFormat('MMM d, y').format(state.endDate),
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

  Widget _buildStep3Review(
    BuildContext context,
    LocalizationService loc,
    EditBudgetPlanFormReady state,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Plan', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _buildReviewRow('Name', state.name),
                const Divider(),
                _buildReviewRow('Category', state.category.displayName),
                const Divider(),
                _buildReviewRow(
                  'Target Amount',
                  'RM ${state.targetAmount.toStringAsFixed(2)}',
                ),
                const Divider(),
                _buildReviewRow(
                  'Target Date',
                  DateFormat('MMM d, y').format(state.endDate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(value, style: AppTextStyles.bodySemiBold),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    EditBudgetPlanFormReady state,
  ) {
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
          Expanded(
            child: AppButton.primary(
              label: 'Save Changes',
              icon: Icons.save,
              onPressed: () {
                context.read<EditBudgetPlanFormBloc>().add(
                  SaveEditBudgetPlan(),
                );
              },
              isLoading: state.isLoading,
            ),
          ),
        ],
      ),
    );
  }
}
