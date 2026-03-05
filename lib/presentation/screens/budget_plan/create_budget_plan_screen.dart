import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/domain/entities/budget_plan/budget_plan_enums.dart';
import 'package:wise_spends/domain/repositories/budget_plan_params.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_bloc.dart';
import 'package:wise_spends/presentation/blocs/budget_plan/budget_plan_list_event.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Create Budget Plan Screen - 3-step wizard
/// Step 1: Plan Basics (name, category, color)
/// Step 2: Financial Goals (target amount, dates)
/// Step 3: Milestones (optional)
class CreateBudgetPlanScreen extends StatefulWidget {
  const CreateBudgetPlanScreen({super.key});

  @override
  State<CreateBudgetPlanScreen> createState() => _CreateBudgetPlanScreenState();
}

class _CreateBudgetPlanScreenState extends State<CreateBudgetPlanScreen> {
  int _currentStep = 0;
  final _formKey = GlobalKey<FormState>();

  // Step 1: Plan Basics
  BudgetPlanCategory _selectedCategory = BudgetPlanCategory.custom;
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _selectedColor = WiseSpendsColors.primary;

  // Step 2: Financial Goals
  final _targetAmountController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 365));

  // Step 3: Milestones
  final List<_MilestoneInput> _milestones = [];

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
    final loc = LocalizationService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Name
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: loc.get('budget_plans.plan_name'),
              hintText: loc.get('budget_plans.plan_name_hint'),
              prefixIcon: const Icon(Icons.flag_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return loc.get('error.validation.required');
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Description
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: loc.get('budget_plans.description'),
              hintText: loc.get('budget_plans.description_hint'),
              prefixIcon: const Icon(Icons.note_outlined),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),

          // Category Selection
          Text(
            loc.get('budget_plans.category'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: BudgetPlanCategory.values.map((category) {
              final isSelected = _selectedCategory == category;
              return FilterChip(
                label: Text(category.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                avatar: Text(category.iconCode),
                selectedColor: WiseSpendsColors.primary.withValues(alpha: 0.2),
                checkmarkColor: WiseSpendsColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Color Selection
          Text(
            loc.get('budget_plans.accent_color'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildColorOption(WiseSpendsColors.primary),
              const SizedBox(width: 8),
              _buildColorOption(WiseSpendsColors.secondary),
              const SizedBox(width: 8),
              _buildColorOption(WiseSpendsColors.tertiary),
              const SizedBox(width: 8),
              _buildColorOption(WiseSpendsColors.warning),
              const SizedBox(width: 8),
              _buildColorOption(WiseSpendsColors.info),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _selectedColor == color;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
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

  Widget _buildStep2FinancialGoals() {
    final loc = LocalizationService();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target Amount
          Text(
            loc.get('budget_plans.target_amount'),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: WiseSpendsColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: WiseSpendsColors.divider),
            ),
            child: Row(
              children: [
                Text(
                  'RM',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: WiseSpendsColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: _targetAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return loc.get('error.validation.required');
                      }
                      if (double.tryParse(value) == null) {
                        return loc.get('error.validation.invalid');
                      }
                      if (double.parse(value) <= 0) {
                        return loc.get('error.validation.amount_positive');
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Start Date
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _startDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked;
                });
              }
            },
            child: _buildDateSelector(
              label: loc.get('budget_plans.start_date'),
              date: _startDate,
            ),
          ),
          const SizedBox(height: 16),

          // Target Date
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _targetDate,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
              );
              if (picked != null) {
                setState(() {
                  _targetDate = picked;
                });
              }
            },
            child: _buildDateSelector(
              label: loc.get('budget_plans.target_date'),
              date: _targetDate,
            ),
          ),
          const SizedBox(height: 24),

          // Auto Calculation
          _buildAutoCalculation(),
        ],
      ),
    );
  }

  Widget _buildDateSelector({required String label, required DateTime date}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WiseSpendsColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: WiseSpendsColors.divider),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_today_outlined,
            color: WiseSpendsColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: WiseSpendsColors.textHint,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d, y').format(date),
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const Spacer(),
          const Icon(
            Icons.chevron_right,
            color: WiseSpendsColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildAutoCalculation() {
    final loc = LocalizationService();

    final targetAmount = double.tryParse(_targetAmountController.text) ?? 0;
    final duration = _targetDate.difference(_startDate).inDays;
    final months = duration / 30;
    final monthlySaving = months > 0 ? targetAmount / months : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: WiseSpendsColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: WiseSpendsColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: WiseSpendsColors.primary),
              const SizedBox(width: 8),
              Text(
                loc.get('budget_plans.auto_calculation'),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: WiseSpendsColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.get('budget_plans.duration'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '${months.toStringAsFixed(1)} ${loc.get('general.months')}',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                loc.get('budget_plans.monthly_saving_needed'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                NumberFormat.currency(
                  symbol: 'RM ',
                  decimalDigits: 2,
                ).format(monthlySaving),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: WiseSpendsColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep3Milestones() {
    final loc = LocalizationService();

    return Column(
      children: [
        Expanded(
          child: _milestones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.flag_outlined,
                        size: 64,
                        color: WiseSpendsColors.textHint,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No milestones added',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: WiseSpendsColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Break your goal into smaller targets (optional)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: WiseSpendsColors.textHint,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _milestones.length,
                  itemBuilder: (context, index) {
                    return _buildMilestoneItem(index);
                  },
                ),
        ),

        // Add milestone button
        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            onPressed: _addMilestone,
            icon: const Icon(Icons.add),
            label: Text(loc.get('budget_plans.add_milestone')),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneItem(int index) {
    final milestone = _milestones[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM ${milestone.targetAmount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: WiseSpendsColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: WiseSpendsColors.secondary,
              ),
              onPressed: () {
                setState(() {
                  _milestones.removeAt(index);
                });
              },
            ),
          ],
        ),
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
                onPressed: _currentStep < 2 ? _nextStep : _createPlan,
                child: Text(
                  _currentStep < 2
                      ? loc.get('general.next')
                      : loc.get('budget_plans.create_plan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addMilestone() {
    showDialog(
      context: context,
      builder: (context) => _MilestoneDialog(
        onAdd: (title, amount, dueDate) {
          setState(() {
            _milestones.add(
              _MilestoneInput(
                title: title,
                targetAmount: amount,
                dueDate: dueDate,
              ),
            );
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    } else if (_currentStep == 1) {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _createPlan() {
    if (_formKey.currentState!.validate()) {
      final targetAmount = double.parse(_targetAmountController.text);

      final milestones = _milestones
          .map(
            (m) => CreateMilestoneParams(
              title: m.title,
              targetAmount: m.targetAmount,
              dueDate: m.dueDate,
            ),
          )
          .toList();

      final params = CreateBudgetPlanParams(
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        category: _selectedCategory,
        targetAmount: targetAmount,
        startDate: _startDate,
        targetDate: _targetDate,
        colorHex:
            '#${_selectedColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2, 8)}',
        milestones: milestones.isEmpty ? null : milestones,
      );

      // Get repository and create plan
      final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();

      repository
          .createPlan(params)
          .then((_) {
            // Notify list BLoC to reload
            if (mounted) {
              context.read<BudgetPlanListBloc>().add(LoadBudgetPlans());

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 12),
                      Text(LocalizationService().get('budget_plans.created')),
                    ],
                  ),
                  backgroundColor: WiseSpendsColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
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
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          });
    }
  }
}

class _MilestoneInput {
  final String title;
  final double targetAmount;
  final DateTime? dueDate;

  _MilestoneInput({
    required this.title,
    required this.targetAmount,
    this.dueDate,
  });
}

class _MilestoneDialog extends StatefulWidget {
  final Function(String, double, DateTime?) onAdd;

  const _MilestoneDialog({required this.onAdd});

  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = LocalizationService();

    return AlertDialog(
      title: Text(loc.get('budget_plans.add_milestone')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: loc.get('budget_plans.milestone_title'),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: InputDecoration(
              labelText: loc.get('budget_plans.milestone_target'),
              prefixText: 'RM ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(
              _dueDate != null
                  ? DateFormat('MMM d, y').format(_dueDate!)
                  : loc.get('budget_plans.milestone_due'),
            ),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null) {
                setState(() {
                  _dueDate = picked;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(loc.get('general.cancel')),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty &&
                _amountController.text.isNotEmpty) {
              widget.onAdd(
                _titleController.text,
                double.parse(_amountController.text),
                _dueDate,
              );
            }
          },
          child: Text(loc.get('general.add')),
        ),
      ],
    );
  }
}
