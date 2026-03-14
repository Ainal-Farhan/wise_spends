// transaction_amount_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wise_spends/core/config/localization_service.dart';
import 'package:wise_spends/features/transaction/domain/entities/transaction_entity.dart';
import 'package:wise_spends/shared/theme/app_text_styles.dart';

/// Large, visually prominent amount input with currency prefix
class TransactionAmountField extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.2), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'transaction.add.amount'.tr,
            style: AppTextStyles.bodySmall.copyWith(
              color: typeColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'RM',
                style: AppTextStyles.amountMedium.copyWith(
                  color: typeColor.withValues(alpha: 0.6),
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textAlign: TextAlign.left,
                  style: AppTextStyles.amountXLarge.copyWith(
                    color: typeColor,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    hintText: '0.00',
                    hintStyle: AppTextStyles.amountXLarge.copyWith(
                      color: typeColor.withValues(alpha: 0.25),
                      fontSize: 36,
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
