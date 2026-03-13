// FIXED: Implemented create budget sheet with full functionality
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget/domain/entities/budget_entity.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_bloc.dart';
import 'package:wise_spends/features/budget/presentation/bloc/budget_event.dart';
import 'package:wise_spends/features/category/domain/entities/category_entity.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_bloc.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_event.dart';
import 'package:wise_spends/features/category/presentation/bloc/category_state.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Create budget bottom sheet with full form
class CreateBudgetSheet extends StatefulWidget {
  const CreateBudgetSheet({super.key});

  @override
  State<CreateBudgetSheet> createState() => _CreateBudgetSheetState();
}

class _CreateBudgetSheetState extends State<CreateBudgetSheet> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  BudgetPeriod _period = BudgetPeriod.monthly;
  CategoryEntity? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    context.read<CategoryBloc>().add(LoadExpenseCategoriesEvent());
    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // Title
              Text('budgets.create'.tr, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xxl),

              // Name field
              AppTextField(
                label: 'budgets.name'.tr,
                hint: 'budgets.name_hint'.tr,
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'error.validation.required'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Amount field
              AppTextField(
                label: 'budgets.limit_amount'.tr,
                hint: '0.00',
                controller: _amountCtrl,
                keyboardType: AppTextFieldKeyboardType.decimal,
                prefixText: 'RM ',
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'error.validation.required'.tr;
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'budgets.error.valid_amount'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Period selector
              Text(
                'budgets.period'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: BudgetPeriod.values.map((period) {
                  final isSelected = _period == period;
                  return ChoiceChip(
                    label: Text(_getPeriodLabel(period)),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _period = period);
                    },
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    labelStyle: AppTextStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Category picker
              Text(
                'budgets.category'.tr,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, state) {
                    List<CategoryEntity> categories = [];
                    if (state is ExpenseCategoriesLoaded) {
                      categories = state.categories;
                    }

                    return DropdownButtonFormField<CategoryEntity>(
                      initialValue: _selectedCategory,
                      decoration: InputDecoration(
                        hintText: 'budgets.select_category'.tr,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Row(
                            children: [
                              Icon(
                                IconData(
                                  int.tryParse(cat.iconCodePoint) ?? 0,
                                  fontFamily: cat.iconFontFamily,
                                ),
                                size: 20,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(cat.name),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCategory = value);
                      },
                      validator: (v) {
                        if (v == null) {
                          return 'budgets.error.select_category'.tr;
                        }
                        return null;
                      },
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.xxl),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      label: 'general.cancel'.tr,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      label: 'general.create'.tr,
                      onPressed: _isLoading ? null : _createBudget,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _createBudget() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    final now = DateTime.now();

    final budget = BudgetEntity(
      id: '',
      name: _nameCtrl.text,
      categoryId: _selectedCategory!.id,
      limitAmount: amount,
      spentAmount: 0,
      period: _period,
      startDate: now,
      endDate: _calculateEndDate(now, _period),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );

    context.read<BudgetBloc>().add(
      CreateBudgetEvent(
        name: budget.name,
        amount: budget.limitAmount,
        categoryId: budget.categoryId,
        startDate: budget.startDate,
        endDate: budget.endDate,
        period: budget.period,
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budgets.created'.tr),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  DateTime _calculateEndDate(DateTime start, BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return start.add(const Duration(days: 1));
      case BudgetPeriod.weekly:
        return start.add(const Duration(days: 7));
      case BudgetPeriod.monthly:
        return DateTime(start.year, start.month + 1, start.day);
      case BudgetPeriod.yearly:
        return DateTime(start.year + 1, start.month, start.day);
    }
  }

  String _getPeriodLabel(BudgetPeriod period) {
    switch (period) {
      case BudgetPeriod.daily:
        return 'budgets.period_day'.tr;
      case BudgetPeriod.weekly:
        return 'budgets.period_week'.tr;
      case BudgetPeriod.monthly:
        return 'budgets.period_month'.tr;
      case BudgetPeriod.yearly:
        return 'budgets.period_year'.tr;
    }
  }
}
