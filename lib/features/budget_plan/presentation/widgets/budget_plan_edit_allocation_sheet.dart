import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/allocation_input.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Edit allocation sheet widget - allows updating allocated amount for linked account
class EditAllocationSheet extends StatefulWidget {
  final String planId;
  final String accountId;
  final double currentAmount;

  const EditAllocationSheet({
    super.key,
    required this.planId,
    required this.accountId,
    required this.currentAmount,
  });

  @override
  State<EditAllocationSheet> createState() => _EditAllocationSheetState();
}

class _EditAllocationSheetState extends State<EditAllocationSheet> {
  late double _allocatedAmount;
  bool _isLoading = true;
  double _maxAmount = 0;

  @override
  void initState() {
    super.initState();
    _allocatedAmount = widget.currentAmount;
    _loadAccountBalance();
  }

  Future<void> _loadAccountBalance() async {
    setState(() => _isLoading = true);
    try {
      final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getSavingRepository();
      final account = await repository.getSavingById(widget.accountId);
      
      setState(() {
        // Use account's current balance as max, or current allocation if account not found
        _maxAmount = account?.saving.currentAmount ?? widget.currentAmount;
        if (_maxAmount < widget.currentAmount) {
          // If account balance is less than current allocation,
          // allow at least the current allocation amount
          _maxAmount = widget.currentAmount;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _maxAmount = widget.currentAmount;
        _isLoading = false;
      });
    }
  }

  void _onAmountChanged(double value) {
    setState(() {
      _allocatedAmount = value;
    });
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
      ),
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
                  color: Theme.of(context).colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'budget_plans.edit_allocation'.tr,
                        style: AppTextStyles.h2,
                      ),
                      Text(
                        'budget_plans.edit_allocation_desc'.tr,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Current amount display
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'budget_plans.current_allocation'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'RM ${widget.currentAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Allocation amount input with slider
            AllocationInput(
              initialValue: _allocatedAmount,
              maxAmount: _maxAmount,
              label: 'budget_plans.allocated_amount'.tr,
              onChanged: _onAmountChanged,
              isLoading: _isLoading,
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
                    label: 'budget_plans.update_allocation'.tr,
                    onPressed: _isLoading ? null : _validateAndSubmit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  void _validateAndSubmit() {
    BlocProvider.of<BudgetPlanDetailBloc>(context).add(
      UpdateAllocationEvent(
        accountId: widget.accountId,
        allocatedAmount: _allocatedAmount,
      ),
    );
    Navigator.pop(context);
  }
}
