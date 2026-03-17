import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/core/di/i_repository_locator.dart';
import 'package:wise_spends/core/utils/singleton_util.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_bloc.dart';
import 'package:wise_spends/features/budget_plan/presentation/bloc/budget_plan_detail_event.dart';
import 'package:wise_spends/features/budget_plan/presentation/widgets/allocation_input.dart';
import 'package:wise_spends/features/saving/domain/entities/saving_vo.dart';
import 'package:wise_spends/shared/components/app_button.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Link account sheet widget - allows linking savings accounts to budget plan
class LinkAccountSheet extends StatefulWidget {
  final String planId;

  const LinkAccountSheet({super.key, required this.planId});

  @override
  State<LinkAccountSheet> createState() => _LinkAccountSheetState();
}

class _LinkAccountSheetState extends State<LinkAccountSheet> {
  final _formKey = GlobalKey<FormState>();
  final _accountCtrl = TextEditingController();
  String? _selectedAccountId;
  bool _isLoading = true;
  List<SavingVO> _accounts = [];
  double _allocatedAmount = 0;
  double _maxAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final repository = SingletonUtil.getSingleton<IRepositoryLocator>()!
          .getBudgetPlanRepository();
      final accounts = await repository.getAvailableSavingsAccounts(
        widget.planId,
      );
      setState(() {
        _accounts = accounts;
        _isLoading = false;
        // Set default max to a reasonable value if no account selected yet
        _maxAmount = 1000;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onAccountSelected(SavingVO account) {
    setState(() {
      _selectedAccountId = account.savingId;
      _accountCtrl.text = account.savingName ?? 'Unnamed Account';
      // Update max amount based on selected account's balance
      _maxAmount = account.currentAmount ?? 0;
      _allocatedAmount = 0;
    });
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccountPickerSheet(
        accounts: _accounts,
        selectedId: _selectedAccountId,
        onSelected: (account) {
          _onAccountSelected(account);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _onAmountChanged(double value) {
    setState(() {
      _allocatedAmount = value;
    });
  }

  @override
  void dispose() {
    _accountCtrl.dispose();
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Icon(
                      Icons.add_link,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'budget_plans.link_account'.tr,
                          style: AppTextStyles.h2,
                        ),
                        Text(
                          'budget_plans.link_account_desc'.tr,
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

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_accounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'budget_plans.no_savings_to_link'.tr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else ...[
                // Account picker field
                AppTextField(
                  controller: _accountCtrl,
                  label: 'budget_plans.select_savings_account'.tr,
                  hint: 'budget_plans.select_account_hint'.tr,
                  readOnly: true,
                  suffixIcon: Icons.keyboard_arrow_down_rounded,
                  prefixWidget: _selectedAccountId != null
                      ? Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.savings_rounded,
                              color: Theme.of(context).colorScheme.primary,
                              size: 14,
                            ),
                          ),
                        )
                      : null,
                  onTap: _showAccountPicker,
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Allocation amount input with slider
                AllocationInput(
                  initialValue: 0,
                  maxAmount: _maxAmount,
                  label: 'budget_plans.allocated_amount'.tr,
                  onChanged: _onAmountChanged,
                  isLoading: false,
                ),
              ],
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
                      label: 'budget_plans.link_account'.tr,
                      onPressed: _selectedAccountId == null
                          ? null
                          : _linkAccount,
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

  void _linkAccount() {
    if (!_formKey.currentState!.validate()) return;

    BlocProvider.of<BudgetPlanDetailBloc>(context).add(
      LinkAccountEvent(
        accountId: _selectedAccountId!,
        allocatedAmount: _allocatedAmount,
      ),
    );
    Navigator.pop(context);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom sheet picker for accounts
// ─────────────────────────────────────────────────────────────────────────────

class _AccountPickerSheet extends StatelessWidget {
  final List<SavingVO> accounts;
  final String? selectedId;
  final ValueChanged<SavingVO> onSelected;

  const _AccountPickerSheet({
    required this.accounts,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Title
          Text(
            'budget_plans.select_savings_account'.tr,
            style: AppTextStyles.h3,
          ),
          const SizedBox(height: 16),

          // Account tiles
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: accounts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final account = accounts[index];
                final isSelected = account.savingId == selectedId;
                return _AccountTile(
                  account: account,
                  isSelected: isSelected,
                  onTap: () => onSelected(account),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final SavingVO account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.06)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
                : Theme.of(context).colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.savings_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.savingName ?? 'Unnamed Account',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'RM ${account.currentAmount?.toStringAsFixed(2) ?? '0.00'}',
              style: AppTextStyles.bodySmall.copyWith(
                color: isSelected
                    ? Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isSelected
                  ? Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                      key: ValueKey('check'),
                    )
                  : Icon(
                      Icons.circle_outlined,
                      color: Theme.of(context).colorScheme.outline,
                      size: 18,
                      key: ValueKey('empty'),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
