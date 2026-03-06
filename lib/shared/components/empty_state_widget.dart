import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';
import 'package:wise_spends/shared/theme/app_spacing.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'app_button.dart';

/// Empty state types for different scenarios
enum EmptyStateType {
  /// No items - generic empty state
  noItems,

  /// No transactions
  noTransactions,

  /// No budgets
  noBudgets,

  /// No budget plans
  noBudgetPlans,

  /// No savings
  noSavings,

  /// No search results
  noSearchResults,

  /// No notifications
  noNotifications,

  /// No data for reports
  noReports,

  /// No categories
  noCategories,

  /// Permission denied
  permissionDenied,

  /// Offline state
  offline,
}

/// WiseSpends EmptyStateWidget Component
///
/// A standardized empty state component for displaying when there's no data.
///
/// Features:
/// - Pre-configured types for common scenarios
/// - Custom illustration support
/// - Clear, descriptive messaging
/// - Optional CTA button
/// - Consistent styling
///
/// Usage:
/// ```dart
/// // Generic empty state
/// EmptyStateWidget(
///   icon: Icons.inbox,
///   title: 'No items yet',
///   subtitle: 'Add your first item to get started',
/// )
///
/// // With action button
/// EmptyStateWidget(
///   icon: Icons.receipt_long,
///   title: 'No transactions',
///   subtitle: 'Start tracking your finances',
///   actionLabel: 'Add Transaction',
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

  /// Pre-configured empty state by type
  factory EmptyStateWidget.type({
    required EmptyStateType type,
    VoidCallback? onAction,
  }) {
    switch (type) {
      case EmptyStateType.noItems:
        return EmptyStateWidget(
          icon: Icons.inbox_outlined,
          title: 'No items yet',
          subtitle: 'Add your first item to get started',
          actionLabel: 'Add Item',
          onAction: onAction,
          iconColor: AppColors.primary,
        );
      case EmptyStateType.noTransactions:
        return EmptyStateWidget(
          icon: Icons.receipt_long_outlined,
          title: 'No transactions yet',
          subtitle:
              'Start tracking your finances by adding your first transaction',
          actionLabel: 'Add Transaction',
          onAction: onAction,
          iconColor: AppColors.primary,
        );
      case EmptyStateType.noBudgets:
        return EmptyStateWidget(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No budgets set',
          subtitle: 'Create a budget to track your spending and stay on track',
          actionLabel: 'Create Budget',
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noBudgetPlans:
        return EmptyStateWidget(
          icon: Icons.savings_outlined,
          title: 'No budget plans',
          subtitle: 'Create a budget plan to track your savings goals',
          actionLabel: 'Create Plan',
          onAction: onAction,
          iconColor: AppColors.tertiary,
        );
      case EmptyStateType.noSavings:
        return EmptyStateWidget(
          icon: Icons.savings_outlined,
          title: 'No savings yet',
          subtitle: 'Start saving by adding your first savings account',
          actionLabel: 'Add Savings',
          onAction: onAction,
          iconColor: AppColors.success,
        );
      case EmptyStateType.noSearchResults:
        return EmptyStateWidget(
          icon: Icons.search_off_outlined,
          title: 'No results found',
          subtitle: 'Try adjusting your search terms or filters',
          iconColor: AppColors.textHint,
        );
      case EmptyStateType.noNotifications:
        return EmptyStateWidget(
          icon: Icons.notifications_none,
          title: 'No notifications',
          subtitle: 'You\'re all caught up! Notifications will appear here',
          iconColor: AppColors.info,
        );
      case EmptyStateType.noReports:
        return EmptyStateWidget(
          icon: Icons.insights_outlined,
          title: 'No data available',
          subtitle: 'Add some transactions to see your financial insights',
          iconColor: AppColors.info,
        );
      case EmptyStateType.noCategories:
        return EmptyStateWidget(
          icon: Icons.category_outlined,
          title: 'No categories',
          subtitle: 'Add categories to organize your transactions',
          actionLabel: 'Add Category',
          onAction: onAction,
          iconColor: AppColors.warning,
        );
      case EmptyStateType.permissionDenied:
        return EmptyStateWidget(
          icon: Icons.block_outlined,
          title: 'Permission denied',
          subtitle: 'Please enable the required permissions in settings',
          actionLabel: 'Open Settings',
          onAction: onAction,
          iconColor: AppColors.secondary,
        );
      case EmptyStateType.offline:
        return EmptyStateWidget(
          icon: Icons.cloud_off_outlined,
          title: 'You\'re offline',
          subtitle:
              'Some features may be limited. Check your internet connection.',
          actionLabel: 'Retry',
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
              // Icon or illustration
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

              // Custom content (optional)
              if (customContent != null) ...[
                customContent!,
                const SizedBox(height: AppSpacing.lg),
              ],

              // Title
              Text(
                title,
                style: AppTextStyles.emptyStateTitle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                subtitle,
                style: AppTextStyles.emptyStateSubtitle,
                textAlign: TextAlign.center,
              ),

              // Action buttons
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

              // Secondary action button
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

/// Specialized empty state for transactions
class NoTransactionsEmptyState extends StatelessWidget {
  final VoidCallback? onAddTransaction;

  const NoTransactionsEmptyState({super.key, this.onAddTransaction});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      subtitle: 'Start tracking your finances by adding your first transaction',
      actionLabel: 'Add Transaction',
      onAction: onAddTransaction,
      iconColor: AppColors.primary,
    );
  }
}

/// Specialized empty state for budgets
class NoBudgetsEmptyState extends StatelessWidget {
  final VoidCallback? onAddBudget;

  const NoBudgetsEmptyState({super.key, this.onAddBudget});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No budgets set',
      subtitle: 'Create a budget to track your spending and stay on track',
      actionLabel: 'Create Budget',
      onAction: onAddBudget,
      iconColor: AppColors.tertiary,
    );
  }
}

/// Specialized empty state for budget plans
class NoBudgetPlansEmptyState extends StatelessWidget {
  final VoidCallback? onCreatePlan;

  const NoBudgetPlansEmptyState({super.key, this.onCreatePlan});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.savings_outlined,
      title: 'No budget plans',
      subtitle: 'Create a budget plan to track your savings goals',
      actionLabel: 'Create Plan',
      onAction: onCreatePlan,
      iconColor: AppColors.tertiary,
    );
  }
}

/// Specialized empty state for search results
class NoSearchResultsEmptyState extends StatelessWidget {
  const NoSearchResultsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No results found',
      subtitle: 'Try adjusting your search terms or filters',
      iconColor: AppColors.textHint,
    );
  }
}

/// Specialized empty state for reports/analytics
class NoReportsEmptyState extends StatelessWidget {
  const NoReportsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const EmptyStateWidget(
      icon: Icons.insights_outlined,
      title: 'No data available',
      subtitle: 'Add some transactions to see your financial insights',
      iconColor: AppColors.info,
    );
  }
}

/// Error state widget
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
      title: 'Oops! Something went wrong',
      subtitle: message,
      actionLabel: actionLabel ?? (showRetry ? 'Retry' : null),
      onAction: onAction,
      iconColor: AppColors.secondary,
    );
  }
}
