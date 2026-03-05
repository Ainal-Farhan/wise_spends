import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/domain/repositories/budget_plan_params.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_event.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Edit Budget Plan Screen - 3-step wizard (similar to Create but pre-filled)
class EditBudgetPlanScreen extends StatefulWidget {
  final String planUuid;

  const EditBudgetPlanScreen({super.key, required this.planUuid});

  @override
  State<EditBudgetPlanScreen> createState() => _EditBudgetPlanScreenState();
}

class _EditBudgetPlanScreenState extends State<EditBudgetPlanScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Plan Basics
  BudgetPlanCategory _selectedCategory = BudgetPlanCategory.custom;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Step 2: Financial Goals
  final _targetAmountController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  // Step 3: Milestones (would load existing)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlanData();
  }

  Future<void> _loadPlanData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();
      final plan = await repository.getPlanByUuid(widget.planUuid);

      if (plan != null && mounted) {
        setState(() {
          _nameController.text = plan.name;
          _descriptionController.text = plan.description ?? '';
          _selectedCategory = plan.category;
          _targetAmountController.text = plan.targetAmount.toString();
          _targetDate = plan.targetDate;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load plan: ${e.toString()}'),
            backgroundColor: WiseSpendsColors.error,
          ),
        );
      }
    }
  }

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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(loc.get('budget_plans.edit'))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.get('budget_plans.edit')),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updatePlan,
            tooltip: loc.get('general.save'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step indicator
          _buildStepIndicator(),

          // Form content
          Expanded(
            child: Form(
              key: _formKey,
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildStep1PlanBasics(),
                  _buildStep2FinancialGoals(),
                  _buildStep3Milestones(),
                ],
              ),
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    final loc = LocalizationService();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildStepIndicatorItem(0, loc.get('budget_plans.step_basics')),
          const SizedBox(width: 8),
          _buildStepIndicatorItem(1, loc.get('budget_plans.step_financial')),
          const SizedBox(width: 8),
          _buildStepIndicatorItem(2, loc.get('budget_plans.step_milestones')),
        ],
      ),
    );
  }

  Widget _buildStepIndicatorItem(int step, String label) {
    final isActive = step == _currentStep;
    final isCompleted = step < _currentStep;

    return Expanded(
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive
                  ? WiseSpendsColors.primary
                  : isCompleted
                  ? WiseSpendsColors.success
                  : WiseSpendsColors.divider,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 18, color: Colors.white)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive
                            ? Colors.white
                            : WiseSpendsColors.textSecondary,
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
                color: isActive
                    ? WiseSpendsColors.textPrimary
                    : WiseSpendsColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1PlanBasics() {
    // Similar to CreateBudgetPlanScreen but pre-filled
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Plan Name',
              prefixIcon: Icon(Icons.flag_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a plan name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              prefixIcon: Icon(Icons.note_outlined),
            ),
            maxLines: 3,
          ),
          // ... rest similar to CreateBudgetPlanScreen
        ],
      ),
    );
  }

  Widget _buildStep2FinancialGoals() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Target Amount',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _targetAmountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: 'RM ',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter target amount';
              }
              if (double.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          // ... rest similar to CreateBudgetPlanScreen
        ],
      ),
    );
  }

  Widget _buildStep3Milestones() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: WiseSpendsColors.textHint),
          const SizedBox(height: 16),
          const Text('Milestone editing coming soon'),
          const SizedBox(height: 8),
          Text(
            'You can manage milestones from the plan detail screen',
            style: TextStyle(color: WiseSpendsColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final loc = LocalizationService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  child: Text(loc.get('general.back')),
                ),
              ),
            if (_currentStep > 0) const SizedBox(width: 16),
            Expanded(
              flex: _currentStep > 0 ? 2 : 1,
              child: ElevatedButton(
                onPressed: _currentStep < 2 ? _nextStep : _updatePlan,
                child: Text(
                  _currentStep < 2
                      ? loc.get('general.next')
                      : loc.get('general.save'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _updatePlan() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.parse(_targetAmountController.text);

      final params = UpdateBudgetPlanParams(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        category: _selectedCategory,
        targetAmount: targetAmount,
        targetDate: _targetDate,
      );

      final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();

      repository
          .updatePlan(widget.planUuid, params)
          .then((_) {
            if (mounted) {
              context.read<BudgetPlanListBloc>().add(LoadBudgetPlans());

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Plan updated successfully'),
                    ],
                  ),
                  backgroundColor: WiseSpendsColors.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );

              Navigator.pop(context);
            }
          })
          .catchError((error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${error.toString()}'),
                  backgroundColor: WiseSpendsColors.error,
                ),
              );
            }
          });
    }
  }
}
