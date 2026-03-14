import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';

/// Widget to display formatted amount with color coding based on transaction type
class AmountDisplay extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final TextStyle? style;
  final bool showPrefix;
  final bool showCurrencySymbol;
  final String currencySymbol;
  final String? note;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.type,
    this.style,
    this.showPrefix = true,
    this.showCurrencySymbol = true,
    this.currencySymbol = 'RM',
    this.note,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getColorForType(colorScheme);
    final prefix = _getPrefixForType();

    // Format amount - show negative for budget plan spending
    final double displayAmount;
    final String amountPrefix;

    if (type == TransactionType.budgetPlanExpense) {
      displayAmount = amount.abs();
      amountPrefix = amount < 0 ? '−' : '+';
    } else if (type == TransactionType.budgetPlanDeposit) {
      displayAmount = amount.abs();
      amountPrefix = '+';
    } else {
      // For other types, use existing logic
      displayAmount = amount.abs();
      amountPrefix = prefix;
    }

    final formattedAmount = NumberFormat.currency(
      symbol: showCurrencySymbol ? currencySymbol : '',
      decimalDigits: 2,
    ).format(displayAmount);

    final displayText = showPrefix
        ? '$amountPrefix$formattedAmount'
        : formattedAmount;

    return Text(
      displayText,
      style: (style ?? const TextStyle()).copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getColorForType(ColorScheme colorScheme) {
    switch (type) {
      case TransactionType.income:
        return colorScheme.primary;
      case TransactionType.expense:
        return colorScheme.secondary;
      case TransactionType.transfer:
        return colorScheme.tertiary;
      case TransactionType.commitment:
        return colorScheme.tertiary;
      case TransactionType.budgetPlanDeposit:
      case TransactionType.budgetPlanExpense:
        return colorScheme.primary;
    }
  }

  String _getPrefixForType() {
    switch (type) {
      case TransactionType.income:
        return '+'; // universally "gaining"
      case TransactionType.expense:
        return '−'; // universally "losing"
      case TransactionType.transfer:
        return '⇄ '; // cleaner than ↔, reads better at small sizes
      case TransactionType.commitment:
        return '↻ '; // signals recurring/scheduled
      case TransactionType.budgetPlanDeposit:
      case TransactionType.budgetPlanExpense:
        return ''; // No prefix - amount sign will be shown via +/- based on context
    }
  }
}

/// Extension to get transaction type from string
extension TransactionTypeExtension on String {
  TransactionType toTransactionType() {
    switch (toLowerCase()) {
      case 'income':
      case 'in':
        return TransactionType.income;
      case 'expense':
      case 'out':
        return TransactionType.expense;
      case 'transfer':
        return TransactionType.transfer;
      default:
        return TransactionType.expense;
    }
  }
}
