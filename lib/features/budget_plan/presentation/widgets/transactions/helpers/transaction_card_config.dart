import 'package:flutter/material.dart';

/// Drives both deposit and spending cards from a single layout widget.
/// Each entry type constructs its own [TransactionCardConfig] to declare
/// what differs: color, icon, amount prefix, and which BLoC event to fire.
class TransactionCardConfig {
  const TransactionCardConfig({
    required this.accentColor,
    required this.icon,
    required this.amountPrefix,
    required this.amountLabel,
    required this.onDelete,
    required this.deleteConfirmKey,
  });

  /// Tint color used for the icon container background and amount text.
  final Color accentColor;

  /// Icon shown in the leading 40×40 container.
  final IconData icon;

  /// Prefix prepended to the formatted amount string, e.g. `'+ RM '`.
  final String amountPrefix;

  /// The formatted amount string shown in the trailing column.
  final String amountLabel;

  /// Called after the user confirms deletion (via swipe or tap).
  final VoidCallback onDelete;

  /// Localisation key for the delete confirmation body text.
  final String deleteConfirmKey;
}
