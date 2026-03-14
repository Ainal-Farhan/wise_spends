import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Transaction type for amount display
enum AmountType {
  /// Income - positive amount with + prefix, green color
  income,

  /// Expense - negative amount with - prefix, red color
  expense,

  /// Transfer - neutral amount with ↔ prefix, blue color
  transfer,

  /// Neutral - no prefix, default color
  neutral,
}

/// WiseSpends AmountText Component
///
/// A standardized component for displaying monetary amounts with
/// automatic formatting, color coding, and type-based prefixes.
///
/// Features:
/// - Automatic currency formatting
/// - Color coding based on transaction type
/// - Prefix symbols (+, -, ↔)
/// - Multiple text styles
/// - Custom currency symbol
/// - Decimal places control
///
/// Usage:
/// ```dart
/// // Income amount
/// AmountText(
///   amount: 1500.00,
///   type: AmountType.income,
/// )
///
/// // Expense amount
/// AmountText(
///   amount: 800.00,
///   type: AmountType.expense,
/// )
///
/// // With custom style
/// AmountText.large(
///   amount: 5000.00,
///   type: AmountType.income,
/// )
///
/// // Neutral amount
/// AmountText(
///   amount: 2500.00,
///   type: AmountType.neutral,
/// )
///
/// // With custom currency
/// AmountText(
///   amount: 100.00,
///   type: AmountType.expense,
///   currencySymbol: '\$',
/// )
/// ```
class AmountText extends StatelessWidget {
  final double amount;
  final AmountType type;
  final TextStyle? style;
  final String currencySymbol;
  final int decimalDigits;
  final bool showPrefix;
  final bool showCurrencySymbol;
  final bool alwaysShowSign;
  final TextAlign textAlign;

  const AmountText({
    super.key,
    required this.amount,
    this.type = AmountType.neutral,
    this.style,
    this.currencySymbol = 'RM',
    this.decimalDigits = 2,
    this.showPrefix = true,
    this.showCurrencySymbol = true,
    this.alwaysShowSign = false,
    this.textAlign = TextAlign.start,
  });

  /// Large amount text for hero displays
  factory AmountText.large({
    required double amount,
    AmountType type = AmountType.neutral,
    String currencySymbol = 'RM',
    int decimalDigits = 2,
    bool showPrefix = true,
    bool showCurrencySymbol = true,
    TextAlign textAlign = TextAlign.start,
  }) {
    return AmountText(
      amount: amount,
      type: type,
      style: AppTextStyles.amountXLarge,
      currencySymbol: currencySymbol,
      decimalDigits: decimalDigits,
      showPrefix: showPrefix,
      showCurrencySymbol: showCurrencySymbol,
      textAlign: textAlign,
    );
  }

  /// Medium amount text for card displays
  factory AmountText.medium({
    required double amount,
    AmountType type = AmountType.neutral,
    String currencySymbol = 'RM',
    int decimalDigits = 2,
    bool showPrefix = true,
    TextAlign textAlign = TextAlign.start,
  }) {
    return AmountText(
      amount: amount,
      type: type,
      style: AppTextStyles.amountMedium,
      currencySymbol: currencySymbol,
      decimalDigits: decimalDigits,
      showPrefix: showPrefix,
      textAlign: textAlign,
    );
  }

  /// Small amount text for list items
  factory AmountText.small({
    required double amount,
    AmountType type = AmountType.neutral,
    String currencySymbol = 'RM',
    int decimalDigits = 2,
    bool showPrefix = true,
    TextAlign textAlign = TextAlign.start,
  }) {
    return AmountText(
      amount: amount,
      type: type,
      style: AppTextStyles.amountSmall,
      currencySymbol: currencySymbol,
      decimalDigits: decimalDigits,
      showPrefix: showPrefix,
      textAlign: textAlign,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getColor(colorScheme);
    final prefix = _getPrefix();
    final formattedAmount = _formatAmount();

    final displayText = showPrefix && prefix.isNotEmpty
        ? '$prefix$formattedAmount'
        : formattedAmount;

    return Text(
      displayText,
      style: (style ?? AppTextStyles.amountMedium).copyWith(
        color: color,
        fontWeight: FontWeight.w700,
      ),
      textAlign: textAlign,
    );
  }

  Color _getColor(ColorScheme colorScheme) {
    switch (type) {
      case AmountType.income:
        return colorScheme.primary;
      case AmountType.expense:
        return colorScheme.secondary;
      case AmountType.transfer:
        return colorScheme.tertiary;
      case AmountType.neutral:
        return style?.color ?? colorScheme.onSurface;
    }
  }

  String _getPrefix() {
    if (!showPrefix && !alwaysShowSign) {
      return '';
    }

    switch (type) {
      case AmountType.income:
        return '+';
      case AmountType.expense:
        return '−'; // Unicode minus sign for better typography
      case AmountType.transfer:
        return '↔ ';
      case AmountType.neutral:
        return alwaysShowSign && amount >= 0 ? '+' : '';
    }
  }

  String _formatAmount() {
    final formatter = NumberFormat.currency(
      symbol: showCurrencySymbol ? currencySymbol : '',
      decimalDigits: decimalDigits,
      customPattern: showCurrencySymbol ? null : '###,##0.##',
    );

    // Always show absolute value - the prefix indicates direction
    return formatter.format(amount.abs());
  }
}

/// Animated amount text that counts up from zero
class AnimatedAmountText extends StatefulWidget {
  final double amount;
  final AmountType type;
  final TextStyle? style;
  final String currencySymbol;
  final int decimalDigits;
  final bool showPrefix;
  final Duration duration;
  final bool animateOnMount;

  const AnimatedAmountText({
    super.key,
    required this.amount,
    this.type = AmountType.neutral,
    this.style,
    this.currencySymbol = 'RM',
    this.decimalDigits = 2,
    this.showPrefix = true,
    this.duration = const Duration(milliseconds: 1000),
    this.animateOnMount = true,
  });

  @override
  State<AnimatedAmountText> createState() => _AnimatedAmountTextState();
}

class _AnimatedAmountTextState extends State<AnimatedAmountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _displayAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: widget.amount,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _animation.addListener(() {
      setState(() {
        _displayAmount = _animation.value;
      });
    });

    if (widget.animateOnMount) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedAmountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.amount != widget.amount) {
      _animation = Tween<double>(
        begin: oldWidget.amount,
        end: widget.amount,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AmountText(
      amount: _displayAmount,
      type: widget.type,
      style: widget.style,
      currencySymbol: widget.currencySymbol,
      decimalDigits: widget.decimalDigits,
      showPrefix: widget.showPrefix,
    );
  }
}

/// Extension to convert TransactionType to AmountType
extension AmountTypeExtension on String {
  AmountType toAmountType() {
    switch (toLowerCase()) {
      case 'income':
        return AmountType.income;
      case 'expense':
        return AmountType.expense;
      case 'transfer':
        return AmountType.transfer;
      default:
        return AmountType.neutral;
    }
  }
}
