import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_colors.dart';

/// Widget to display formatted amount with color coding based on transaction type
class AmountDisplay extends StatelessWidget {
  final double amount;
  final TransactionType type;
  final TextStyle? style;
  final bool showPrefix;
  final bool showCurrencySymbol;
  final String currencySymbol;

  const AmountDisplay({
    super.key,
    required this.amount,
    required this.type,
    this.style,
    this.showPrefix = true,
    this.showCurrencySymbol = true,
    this.currencySymbol = 'RM',
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForType();
    final prefix = _getPrefixForType();
    final formattedAmount = NumberFormat.currency(
      symbol: showCurrencySymbol ? currencySymbol : '',
      decimalDigits: 2,
    ).format(amount.abs());

    final displayText = showPrefix
        ? '$prefix$formattedAmount'
        : formattedAmount;

    return Text(
      displayText,
      style: (style ?? const TextStyle()).copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Color _getColorForType() {
    switch (type) {
      case TransactionType.income:
        return AppColors.income;
      case TransactionType.expense:
        return AppColors.expense;
      case TransactionType.transfer:
        return AppColors.transfer;
      case TransactionType.commitment:
        return AppColors.commitment;
      case TransactionType.budgetPlan:
        return AppColors.budgetPlan;
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
      case TransactionType.budgetPlan:
        return '◎ '; // target/goal — distinct, non-directional
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
