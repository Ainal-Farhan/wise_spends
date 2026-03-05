import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/domain/entities/transaction/transaction_entity.dart';
import 'package:wise_spends/shared/theme/wise_spends_theme.dart';

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

    final displayText = showPrefix ? '$prefix$formattedAmount' : formattedAmount;

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
        return WiseSpendsColors.success;
      case TransactionType.expense:
        return WiseSpendsColors.secondary;
      case TransactionType.transfer:
        return WiseSpendsColors.tertiary;
    }
  }

  String _getPrefixForType() {
    switch (type) {
      case TransactionType.income:
        return '+';
      case TransactionType.expense:
        return '−'; // Unicode minus sign for better typography
      case TransactionType.transfer:
        return '↔ ';
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
