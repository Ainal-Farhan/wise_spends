// Add Milestone Bottom Sheet
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Add Milestone Bottom Sheet
class AddMilestoneBottomSheet extends StatefulWidget {
  final String planId;

  const AddMilestoneBottomSheet({super.key, required this.planId});

  @override
  State<AddMilestoneBottomSheet> createState() =>
      _AddMilestoneBottomSheetState();
}

class _AddMilestoneBottomSheetState extends State<AddMilestoneBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  DateTime? _dueDate;

  @override
  void dispose() {
    _titleCtrl.dispose();
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
              Text('budget_plans.add_milestone'.tr, style: AppTextStyles.h3),
              const SizedBox(height: AppSpacing.xxl),

              // Milestone Title
              AppTextField(
                label: 'budget_plans.milestone_title'.tr,
                hint: 'budget_plans.milestone_title_hint'.tr,
                controller: _titleCtrl,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'error.validation.required'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Target Amount
              AppTextField(
                label: 'budget_plans.target_amount'.tr,
                hint: '0.00',
                controller: _amountCtrl,
                prefixText: 'RM ',
                keyboardType: AppTextFieldKeyboardType.currency,
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'error.validation.required'.tr;
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'error.validation.invalid_amount'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),

              // Due Date (Optional)
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'budget_plans.due_date'.tr,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _dueDate != null
                                  ? DateFormat(
                                      'EEEE, MMMM d, y',
                                    ).format(_dueDate!)
                                  : 'budget_plans.select_due_date'.tr,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: _dueDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                color: _dueDate != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_dueDate != null)
                        GestureDetector(
                          onTap: () {
                            setState(() => _dueDate = null);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.divider,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.chevron_right,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                    ],
                  ),
                ),
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
                      label: 'general.add'.tr,
                      onPressed: _addMilestone,
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _addMilestone() {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text) ?? 0;

    context.read<BudgetPlanDetailBloc>().add(
      AddMilestoneEvent(title: title, targetAmount: amount, dueDate: _dueDate),
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('budget_plans.milestone_added'.tr),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
