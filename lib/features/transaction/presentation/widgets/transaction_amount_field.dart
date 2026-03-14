// transaction_amount_field.dart
import 'package:flutter/material.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/components/app_text_field.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

class TransactionAmountField extends StatefulWidget {
  final TextEditingController controller;
  final TransactionType transactionType;
  final Color typeColor;

  const TransactionAmountField({
    super.key,
    required this.controller,
    required this.transactionType,
    required this.typeColor,
  });

  @override
  State<TransactionAmountField> createState() => _TransactionAmountFieldState();
}

class _TransactionAmountFieldState extends State<TransactionAmountField> {
  late final FocusNode _focusNode;
  bool _isFocused = false;

  List<double> get _quickAmounts => switch (widget.transactionType) {
    TransactionType.income => [500, 1000, 2000, 5000],
    TransactionType.transfer => [100, 500, 1000, 2000],
    _ => [10, 50, 100, 500],
  };

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _applyQuickAmount(double amount) {
    final current = double.tryParse(widget.controller.text) ?? 0;
    final next = current == 0 ? amount : current + amount;
    widget.controller.text = next % 1 == 0
        ? next.toStringAsFixed(0)
        : next.toStringAsFixed(2);
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
    );
  }

  bool get _hasValue => (double.tryParse(widget.controller.text) ?? 0) > 0;

  @override
  Widget build(BuildContext context) {
    final color = widget.typeColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color.withValues(alpha: _isFocused ? 0.07 : 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: _isFocused ? 0.4 : 0.15),
          width: _isFocused ? 1.8 : 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Label ────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 14, 0),
            child: Text(
              'transaction.add.amount'.tr,
              style: AppTextStyles.bodySmall.copyWith(
                color: color.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: 11,
                letterSpacing: 0.4,
              ),
            ),
          ),

          // ── Amount input ─────────────────────────────────────────────
          ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final len = widget.controller.text.length;
              final fontSize = len > 8
                  ? 28.0
                  : len > 6
                  ? 32.0
                  : 38.0;

              return AppTextField(
                hint: '0.00',
                controller: widget.controller,
                focusNode: _focusNode,
                keyboardType: AppTextFieldKeyboardType.currency,
                prefixText: 'RM',
                showClearButton: true,
                suppressContainer: true,
                contentPadding: const EdgeInsets.fromLTRB(18, 6, 14, 14),
                textStyle: AppTextStyles.amountXLarge.copyWith(
                  color: _hasValue ? color : color.withValues(alpha: 0.3),
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
                onChanged: (_) => setState(() {}),
              );
            },
          ),

          // ── Separator ────────────────────────────────────────────────
          Divider(height: 1, thickness: 1, color: color.withValues(alpha: 0.1)),

          // ── Quick amount chips ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  '+',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: color.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: _quickAmounts
                        .map(
                          (amount) => _QuickAmountChip(
                            amount: amount,
                            color: color,
                            onTap: () => _applyQuickAmount(amount),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick amount chip
// ─────────────────────────────────────────────────────────────────────────────

class _QuickAmountChip extends StatelessWidget {
  final double amount;
  final Color color;
  final VoidCallback onTap;

  const _QuickAmountChip({
    required this.amount,
    required this.color,
    required this.onTap,
  });

  String get _label {
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k == k.truncateToDouble() ? k.toInt() : k.toStringAsFixed(1)}k';
    }
    return amount.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.18)),
        ),
        child: Text(
          _label,
          style: AppTextStyles.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
