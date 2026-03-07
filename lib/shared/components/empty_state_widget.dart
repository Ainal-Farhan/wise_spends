import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'app_button.dart';

// =============================================================================
// Enum
// =============================================================================

/// Empty state types for different scenarios
enum EmptyStateType {
  noItems,
  noTransactions,
  noBudgets,
  noBudgetPlans,
  noSavings,
  noSearchResults,
  noNotifications,
  noReports,
  noCategories,
  noMoneyStorage,
  noPayees,
  noCommitments,
  permissionDenied,
  offline,
}

// =============================================================================
// Core widget
// =============================================================================

/// WiseSpends EmptyStateWidget Component
///
/// A standardised empty state component for displaying when there's no data.
///
/// ```dart
/// // Generic
/// EmptyStateWidget(
///   icon: Icons.inbox,
///   title: 'empty.no_items.title'.tr,
///   subtitle: 'empty.no_items.subtitle'.tr,
/// )
///
/// // With primary action
/// EmptyStateWidget(
///   icon: Icons.receipt_long,
///   title: 'empty.no_transactions.title'.tr,
///   subtitle: 'empty.no_transactions.subtitle'.tr,
///   actionLabel: 'empty.no_transactions.action'.tr,
///   onAction: () {},
/// )
///
/// // Pre-configured type
/// EmptyStateWidget.type(
///   type: EmptyStateType.noTransactions,
///   onAction: () {},
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final IconData? icon;
  final Image? illustration;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? secondaryAction;
  final Color? iconColor;
  final double? iconSize;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final Widget? customContent;

  const EmptyStateWidget({
    super.key,
    this.icon,
    this.illustration,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryAction,
    this.iconColor,
    this.iconSize,
    this.maxWidth,
    this.padding,
    this.customContent,
  });

  /// Pre-configured empty state by type — all strings from localization
  factory EmptyStateWidget.type({
    required EmptyStateType type,
    VoidCallback? onAction,
  }) {
    switch (type) {
      case EmptyStateType.noItems:
        return EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'empty.no_items.title'.tr,
          subtitle: 'empty.no_items.subtitle'.tr,
          actionLabel: 'empty.no_items.action'.tr,
          onAction: onAction,
          iconColor: AppColors.primary,
        );
      case EmptyStateType.noTransactions:
        return EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'empty.no_transactions.title'.tr,
          subtitle: 'empty.no_transactions.subtitle'.tr,
          actionLabel: 'empty.no_transactions.action'.tr,
          onAction: onAction,
          iconColor: AppColors.primary,
        );
      case EmptyStateType.noBudgets:
        return EmptyStateWidget(
          icon: Icons.account_balance_wallet_outlined,
          title: 'empty.no_budgets.title'.tr,
          subtitle: 'empty.no_budgets.subtitle'.tr,
          actionLabel: 'empty.no_budgets.action'.tr,
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noBudgetPlans:
        return EmptyStateWidget(
          icon: Icons.savings_outlined,
          title: 'empty.no_budget_plans.title'.tr,
          subtitle: 'empty.no_budget_plans.subtitle'.tr,
          actionLabel: 'empty.no_budget_plans.action'.tr,
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noSavings:
        return EmptyStateWidget(
          icon: Icons.savings_outlined,
          title: 'empty.no_savings.title'.tr,
          subtitle: 'empty.no_savings.subtitle'.tr,
          actionLabel: 'empty.no_savings.action'.tr,
          onAction: onAction,
          iconColor: AppColors.success,
        );
      case EmptyStateType.noSearchResults:
        return EmptyStateWidget(
          icon: Icons.search_off_outlined,
          title: 'empty.no_search.title'.tr,
          subtitle: 'empty.no_search.subtitle'.tr,
          iconColor: AppColors.textHint,
        );
      case EmptyStateType.noNotifications:
        return EmptyStateWidget(
          icon: Icons.notifications_none,
          title: 'empty.no_notifications.title'.tr,
          subtitle: 'empty.no_notifications.subtitle'.tr,
          iconColor: AppColors.info,
        );
      case EmptyStateType.noReports:
        return EmptyStateWidget(
          icon: Icons.insights_outlined,
          title: 'empty.no_reports.title'.tr,
          subtitle: 'empty.no_reports.subtitle'.tr,
          iconColor: AppColors.info,
        );
      case EmptyStateType.noCategories:
        return EmptyStateWidget(
          icon: Icons.category_outlined,
          title: 'empty.no_categories.title'.tr,
          subtitle: 'empty.no_categories.subtitle'.tr,
          actionLabel: 'empty.no_categories.action'.tr,
          onAction: onAction,
          iconColor: AppColors.warning,
        );
      case EmptyStateType.noMoneyStorage:
        return EmptyStateWidget(
          icon: Icons.account_balance_outlined,
          title: 'empty.no_money_storage.title'.tr,
          subtitle: 'empty.no_money_storage.subtitle'.tr,
          actionLabel: 'empty.no_money_storage.action'.tr,
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noPayees:
        return EmptyStateWidget(
          icon: Icons.people_outline,
          title: 'empty.no_payees.title'.tr,
          subtitle: 'empty.no_payees.subtitle'.tr,
          actionLabel: 'empty.no_payees.action'.tr,
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noCommitments:
        return EmptyStateWidget(
          icon: Icons.calendar_month_outlined,
          title: 'empty.no_commitments.title'.tr,
          subtitle: 'empty.no_commitments.subtitle'.tr,
          actionLabel: 'empty.no_commitments.action'.tr,
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.permissionDenied:
        return EmptyStateWidget(
          icon: Icons.block_outlined,
          title: 'empty.permission_denied.title'.tr,
          subtitle: 'empty.permission_denied.subtitle'.tr,
          actionLabel: 'empty.permission_denied.action'.tr,
          onAction: onAction,
          iconColor: AppColors.secondary,
        );
      case EmptyStateType.offline:
        return EmptyStateWidget(
          icon: Icons.cloud_off_outlined,
          title: 'empty.offline.title'.tr,
          subtitle: 'empty.offline.subtitle'.tr,
          actionLabel: 'empty.offline.action'.tr,
          onAction: onAction,
          iconColor: AppColors.textHint,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 320),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Illustration or icon ────────────────────────────────────
              if (illustration != null) ...[
                illustration!,
                const SizedBox(height: AppSpacing.xxl),
              ] else if (icon != null) ...[
                Container(
                  width: iconSize ?? 120,
                  height: iconSize ?? 120,
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.textHint).withValues(
                      alpha: 0.1,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: iconSize != null ? iconSize! * 0.47 : 56,
                    color: iconColor ?? AppColors.textHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],

              // ── Custom content ──────────────────────────────────────────
              if (customContent != null) ...[
                customContent!,
                const SizedBox(height: AppSpacing.lg),
              ],

              // ── Title ───────────────────────────────────────────────────
              Text(
                title,
                style: AppTextStyles.emptyStateTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Subtitle ────────────────────────────────────────────────
              Text(
                subtitle,
                style: AppTextStyles.emptyStateSubtitle,
                textAlign: TextAlign.center,
              ),

              // ── Primary action ──────────────────────────────────────────
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.primary(
                    label: actionLabel!,
                    onPressed: onAction,
                    icon: Icons.add,
                  ),
                ),
              ],

              // ── Secondary action ────────────────────────────────────────
              if (secondaryActionLabel != null && secondaryAction != null) ...[
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: AppButton.text(
                    label: secondaryActionLabel!,
                    onPressed: secondaryAction,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Specialised empty states — thin wrappers that use EmptyStateWidget.type
// so all string logic stays in one place
// =============================================================================

class NoTransactionsEmptyState extends StatelessWidget {
  final VoidCallback? onAddTransaction;
  const NoTransactionsEmptyState({super.key, this.onAddTransaction});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noTransactions,
    onAction: onAddTransaction,
  );
}

class NoBudgetsEmptyState extends StatelessWidget {
  final VoidCallback? onAddBudget;
  const NoBudgetsEmptyState({super.key, this.onAddBudget});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noBudgets,
    onAction: onAddBudget,
  );
}

class NoBudgetPlansEmptyState extends StatelessWidget {
  final VoidCallback? onCreatePlan;
  const NoBudgetPlansEmptyState({super.key, this.onCreatePlan});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noBudgetPlans,
    onAction: onCreatePlan,
  );
}

class NoSavingsEmptyState extends StatelessWidget {
  final VoidCallback? onAddSaving;
  const NoSavingsEmptyState({super.key, this.onAddSaving});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noSavings,
    onAction: onAddSaving,
  );
}

class NoSearchResultsEmptyState extends StatelessWidget {
  const NoSearchResultsEmptyState({super.key});

  @override
  Widget build(BuildContext context) =>
      EmptyStateWidget.type(type: EmptyStateType.noSearchResults);
}

class NoReportsEmptyState extends StatelessWidget {
  const NoReportsEmptyState({super.key});

  @override
  Widget build(BuildContext context) =>
      EmptyStateWidget.type(type: EmptyStateType.noReports);
}

class NoMoneyStorageEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const NoMoneyStorageEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noMoneyStorage,
    onAction: onAdd,
  );
}

class NoPayeesEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const NoPayeesEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) =>
      EmptyStateWidget.type(type: EmptyStateType.noPayees, onAction: onAdd);
}

class NoCommitmentsEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;
  const NoCommitmentsEmptyState({super.key, this.onAdd});

  @override
  Widget build(BuildContext context) => EmptyStateWidget.type(
    type: EmptyStateType.noCommitments,
    onAction: onAdd,
  );
}

// =============================================================================
// Error state
// =============================================================================

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showRetry;

  const ErrorStateWidget({
    super.key,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.showRetry = true,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'error.something_wrong.title'.tr,
      subtitle: message,
      actionLabel: actionLabel ?? (showRetry ? 'general.retry'.tr : null),
      onAction: onAction,
      iconColor: AppColors.secondary,
    );
  }
}
