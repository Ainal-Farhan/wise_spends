import 'package:flutter/material.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

/// Empty state widget for displaying when there's no data
/// Shows illustration, title, subtitle, and optional CTA button
/// Features:
/// - Clean Material 3 design
/// - Customizable icon with background
/// - Clear, descriptive messaging
/// - Optional action button
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;
  final double? iconSize;
  final double? maxWidth;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
    this.iconSize,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 320),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingXXXL),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with background
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: (iconColor ?? WiseSpendsColors.textHint)
                      .withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize ?? 56,
                  color: iconColor ?? WiseSpendsColors.textHint,
                ),
              ),
              const SizedBox(height: UIConstants.spacingXXL),

              // Title
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: WiseSpendsColors.textPrimary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: UIConstants.spacingSmall),

              // Subtitle
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: WiseSpendsColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),

              // Action button (optional)
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: UIConstants.spacingXXL),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.add),
                    label: Text(actionLabel!),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, UIConstants.touchTargetMin),
                    ),
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

  const NoTransactionsEmptyState({
    super.key,
    this.onAddTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      subtitle: 'Start tracking your finances by adding your first transaction',
      actionLabel: 'Add Transaction',
      onAction: onAddTransaction,
      iconColor: WiseSpendsColors.primary,
    );
  }
}

/// Specialized empty state for budgets
class NoBudgetsEmptyState extends StatelessWidget {
  final VoidCallback? onAddBudget;

  const NoBudgetsEmptyState({
    super.key,
    this.onAddBudget,
  });

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.account_balance_wallet_outlined,
      title: 'No budgets set',
      subtitle: 'Create a budget to track your spending and stay on track',
      actionLabel: 'Create Budget',
      onAction: onAddBudget,
      iconColor: WiseSpendsColors.tertiary,
    );
  }
}

/// Specialized empty state for search results
class NoSearchResultsEmptyState extends StatelessWidget {
  const NoSearchResultsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off_outlined,
      title: 'No results found',
      subtitle: 'Try adjusting your search terms or filters',
      iconColor: WiseSpendsColors.textHint,
    );
  }
}

/// Specialized empty state for reports/analytics
class NoReportsEmptyState extends StatelessWidget {
  const NoReportsEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.insights_outlined,
      title: 'No data available',
      subtitle: 'Add some transactions to see your financial insights',
      iconColor: WiseSpendsColors.info,
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
      iconColor: WiseSpendsColors.secondary,
    );
  }
}
