// FIXED: Implemented edit budget sheet with pre-filled values
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

/// Edit budget bottom sheet with pre-filled form values
class EditBudgetSheet extends StatefulWidget {
  final BudgetEntity budget;

  const EditBudgetSheet({super.key, required this.budget});

  @override
  State<EditBudgetSheet> createState() => _EditBudgetSheetState();
}

class _EditBudgetSheetState extends State<EditBudgetSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _amountCtrl;
  final _formKey = GlobalKey<FormState>();
  late BudgetPeriod _period;
  CategoryEntity? _selectedCategory;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill form with existing budget data
    _nameCtrl = TextEditingController(text: widget.budget.name);
    _amountCtrl = TextEditingController(
      text: widget.budget.limitAmount.toStringAsFixed(2),
    );
    _period = widget.budget.period;
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
              Text('budgets.edit_budget'.tr, style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.xxl),

              // Name field (pre-filled)
              AppTextField(
                label: 'budgets.name'.tr,
                hint: 'budgets.name_hint'.tr,
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'budgets.error_name_required'.tr;
                  }
                  if (v.length > 100) {
                    return 'budgets.error_name_too_long'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Amount field (pre-filled)
              AppTextField(
                label: 'budgets.limit_amount'.tr,
                hint: '0.00',
                controller: _amountCtrl,
                keyboardType: AppTextFieldKeyboardType.decimal,
                prefixText: 'RM ',
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'budgets.error_amount_required'.tr;
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'budgets.error_amount_invalid'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Period selector (pre-selected)
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

              // Category picker (pre-selected)
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
                      // Set initial selected category if not already set
                      if (_selectedCategory == null && categories.isNotEmpty) {
                        _selectedCategory = categories.firstWhere(
                          (c) => c.id == widget.budget.categoryId,
                          orElse: () => categories.first,
                        );
                      }
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
                          return 'budgets.error_category_required'.tr;
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
                      label: 'general.update'.tr,
                      onPressed: _isLoading ? null : _updateBudget,
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

  void _updateBudget() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) return;

    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    context.read<BudgetBloc>().add(
      UpdateBudgetEvent(
        budgetId: widget.budget.id,
        name: _nameCtrl.text,
        categoryId: _selectedCategory!.id,
        amount: amount,
        period: _period,
      ),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budgets.update_success'.tr),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
