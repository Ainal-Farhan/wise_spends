import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/presentation/widgets/components/amount_display.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';
import 'package:wise_spends/shared/theme/ui_constants.dart';
import 'package:wise_spends/shared/resources/ui/dialog/dialog.dart';

/// Check if transaction is a budget plan type
bool isBudgetPlanType(TransactionType type) {
  return type == TransactionType.budgetPlanDeposit ||
      type == TransactionType.budgetPlanExpense;
}

/// Reusable transaction card widget
class TransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryIcon;
  final IconData? icon;
  final DateTime date;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onDelete;
  final bool showBudgetPlanIndicator;

  const TransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryIcon,
    this.icon,
    required this.date,
    this.note,
    this.onTap,
    this.onLongPress,
    this.onDelete,
    this.showBudgetPlanIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingSmall),
      elevation: UIConstants.elevationNone,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        side: BorderSide(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.spacingLarge),
          child: Row(
            children: [
              // Category Icon
              _buildIconContainer(context, colorScheme),
              const SizedBox(width: UIConstants.spacingLarge),

              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: UIConstants.spacingXS),
                    Row(
                      children: [
                        Text(
                          _formatDate(date),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                        if (showBudgetPlanIndicator) ...[
                          const SizedBox(width: UIConstants.spacingXS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: UIConstants.spacingXS,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(
                                UIConstants.radiusSmall,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.account_balance_wallet_outlined,
                                  size: 10,
                                  color: colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'budget_plans.linked'.tr,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (note != null &&
                            note!.isNotEmpty &&
                            !showBudgetPlanIndicator) ...[
                          const SizedBox(width: UIConstants.spacingSmall),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.onSurfaceVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: UIConstants.spacingSmall),
                          Expanded(
                            child: Text(
                              _formatNote(note!),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Amount
              AmountDisplay(
                amount: amount,
                type: type,
                style: Theme.of(context).textTheme.titleMedium,
                note: note,
              ),

              // Delete button (optional)
              if (onDelete != null) ...[
                const SizedBox(width: UIConstants.spacingSmall),
                InkWell(
                  onTap: onDelete,
                  borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
                  child: Padding(
                    padding: EdgeInsets.all(UIConstants.spacingSmall),
                    child: Icon(
                      Icons.delete_outline,
                      size: UIConstants.iconMedium,
                      color: colorScheme.onSurfaceVariant,
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

  Widget _buildIconContainer(BuildContext context, ColorScheme colorScheme) {
    // Get background color based on transaction type
    Color backgroundColor;
    IconData defaultIcon;
    Color iconColor;

    defaultIcon = type.icon;
    iconColor = type.getColor(context);

    switch (type) {
      case TransactionType.income:
        backgroundColor = colorScheme.primaryContainer;
        break;
      case TransactionType.expense:
        backgroundColor = colorScheme.secondaryContainer;
        break;
      case TransactionType.transfer:
        backgroundColor = colorScheme.tertiaryContainer;
        break;
      case TransactionType.commitment:
        backgroundColor = colorScheme.tertiaryContainer;
        break;
      case TransactionType.budgetPlanDeposit:
      case TransactionType.budgetPlanExpense:
        backgroundColor = colorScheme.primaryContainer;
        break;
    }

    return Container(
      width: UIConstants.touchTargetMin,
      height: UIConstants.touchTargetMin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
      ),
      child: Icon(
        icon ?? defaultIcon,
        color: iconColor,
        size: UIConstants.iconLarge,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today';
    } else if (transactionDate == yesterday) {
      return 'Yesterday';
    } else {
      // Check if within last 7 days
      final daysAgo = today.difference(transactionDate).inDays;
      if (daysAgo < 7) {
        return DateFormat('EEEE').format(date); // e.g., "Monday"
      }
      return DateFormat('MMM d, y').format(date); // e.g., "Jan 15, 2024"
    }
  }

  /// Format note for display - hides UIDs and shows friendly names
  String _formatNote(String note) {
    return note;
  }
}

/// Transaction card with swipe-to-delete functionality
class SwipeableTransactionCard extends StatelessWidget {
  final String title;
  final double amount;
  final TransactionType type;
  final String? categoryIcon;
  final IconData? icon;
  final DateTime date;
  final String? note;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showBudgetPlanIndicator;

  const SwipeableTransactionCard({
    super.key,
    required this.title,
    required this.amount,
    required this.type,
    this.categoryIcon,
    this.icon,
    required this.date,
    this.note,
    this.onTap,
    this.onDelete,
    this.showBudgetPlanIndicator = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: Key(title + date.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: UIConstants.spacingLarge),
        decoration: BoxDecoration(
          color: colorScheme.secondary,
          borderRadius: BorderRadius.circular(UIConstants.radiusMedium),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: UIConstants.iconXLarge,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog(
          context: context,
          builder: (context) => CustomDialog(
            config: CustomDialogConfig(
              title: 'Delete Transaction?',
              message:
                  'This action cannot be undone. Are you sure you want to delete this transaction?',
              icon: Icons.delete_outline,
              iconColor: colorScheme.secondary,
              buttons: [
                CustomDialogButton(
                  text: 'Cancel',
                  onPressed: () => Navigator.pop(context, false),
                ),
                CustomDialogButton(
                  text: 'Delete',
                  isDestructive: true,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ],
            ),
          ),
        );
      },
      onDismissed: (direction) {
        onDelete?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('transaction.deleted'.tr),
            backgroundColor: colorScheme.inverseSurface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(UIConstants.radiusSmall),
            ),
            action: SnackBarAction(
              label: 'Undo'.tr,
              textColor: Colors.white,
              onPressed: () {
                // Undo is handled by parent BLoC listener
              },
            ),
          ),
        );
      },
      child: TransactionCard(
        title: title,
        amount: amount,
        type: type,
        categoryIcon: categoryIcon,
        icon: icon,
        date: date,
        note: note,
        onTap: onTap,
        showBudgetPlanIndicator: showBudgetPlanIndicator,
      ),
    );
  }
}
